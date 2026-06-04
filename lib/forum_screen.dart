import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==========================================================
// HÀM LẤY CHỮ CÁI ĐẦU TIÊN CỦA TÊN ĐỂ LÀM AVATAR AN TOÀN
// ==========================================================
String _getAvatarInitial(String? name) {
  if (name == null || name.trim().isEmpty) {
    return "?";
  }
  return name.trim()[0].toUpperCase();
}

// ==========================================================
// HÀM LẤY TÊN NGƯỜI DÙNG TỪ FIRESTORE HOẶC AUTH (TỐI ƯU)
// ==========================================================
Future<String> _getAuthorName(User user) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 5));
    if (doc.exists && doc.data() != null) {
      final name = doc.data()!['name'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
  } catch (e) {
    print("Lỗi lấy tên người dùng: $e");
  }

  if (user.displayName != null && user.displayName!.isNotEmpty) return user.displayName!;
  if (user.email != null) return user.email!.split('@').first;
  return "Người chơi";
}

// ==========================================================
// HÀM UPLOAD TOÀN CỤC (GLOBAL FUNCTION) ĐỂ CẢ 2 SCREEN ĐỀU DÙNG ĐƯỢC
// ==========================================================
Future<String?> _uploadImage(File file) async {
  try {
    final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";
    final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "";

    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print("Lỗi: Chưa cấu hình Cloudinary trong file .env");
      return null;
    }

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['upload_preset'] = uploadPreset;

    // Thêm timeout 30s để tránh load vô tận
    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['secure_url'] as String;
    } else {
      print("Cloudinary Upload thất bại với mã lỗi: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Lỗi kết nối khi upload ảnh lên Cloudinary: $e");
    return null;
  }
}

// ==========================================================
// MÀN HÌNH DIỄN ĐÀN (DANH SÁCH BÀI VIẾT)
// ==========================================================
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  bool _isSearching = false;
  String _searchText = "";

  final List<String> _topics = ["Tất cả", "Từ vựng", "Ngữ pháp", "Luyện đọc", "Luyện nghe"];
  String _selectedTopicFilter = "Tất cả";
  String _newPostTopic = "Từ vựng";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchText = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện ảnh'),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                  maxWidth: 1080,
                );
                if (pickedFile != null) {
                  setModalState(() => _imageFile = File(pickedFile.path));
                  setState(() {});
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                  maxWidth: 1080,
                );
                if (pickedFile != null) {
                  setModalState(() => _imageFile = File(pickedFile.path));
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    _postController.clear();
    _imageFile = null;
    _newPostTopic = "Từ vựng"; // Reset topic mặc định cho bài mới

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tạo bài viết mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // CHỌN CHỦ ĐỀ CHO BÀI VIẾT
                  const Text("Chọn chủ đề:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _topics.where((t) => t != "Tất cả").map((topic) {
                        final isSelected = _newPostTopic == topic;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(topic),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setModalState(() => _newPostTopic = topic);
                            },
                            selectedColor: kPrimaryBlue.withOpacity(0.2),
                            labelStyle: TextStyle(color: isSelected ? kPrimaryBlue : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _postController,
                    maxLines: 5,
                    minLines: 1,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: "Bạn đang nghĩ gì về tiếng Nhật?", border: InputBorder.none),
                  ),
                  if (_imageFile != null)
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 15,
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() => _imageFile = null);
                              setState(() => _imageFile = null);
                            },
                            child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.image, color: kPrimaryBlue), onPressed: () => _pickImage(setModalState)),
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : () => _submitPost(setModalState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isUploading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("ĐĂNG BÀI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitPost(StateSetter setModalState) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final content = _postController.text.trim();
    if (content.isEmpty && _imageFile == null) return;

    setModalState(() => _isUploading = true);
    setState(() => _isUploading = true);
    try {
      // Tối ưu: Chạy upload ảnh và lấy tên user song song
      final results = await Future.wait([
        _imageFile != null ? _uploadImage(_imageFile!) : Future.value(null),
        _getAuthorName(user),
      ]);

      final String? uploadedUrl = results[0] as String?;
      final String authorName = results[1] as String;

      await FirebaseFirestore.instance.collection('forum_posts').add({
        'authorId': user.uid,
        'authorName': authorName,
        'content': content,
        'imageUrl': uploadedUrl,
        'topic': _newPostTopic,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'commentCount': 0,
      });
      if (mounted) {
        _postController.clear();
        _imageFile = null;
        Navigator.pop(context);
      }
    } catch (e) {
      print("Lỗi đăng bài: $e");
    } finally {
      if (mounted) {
        setModalState(() => _isUploading = false);
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Tìm kiếm bài viết hoặc tác giả...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              )
            : const Text("Diễn đàn thảo luận", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                final isSelected = _selectedTopicFilter == topic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedTopicFilter = topic);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: kPrimaryBlue.withOpacity(0.2),
                    checkmarkColor: kPrimaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? kPrimaryBlue : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _selectedTopicFilter == "Tất cả"
              ? FirebaseFirestore.instance.collection('forum_posts').orderBy('timestamp', descending: true).snapshots()
              : FirebaseFirestore.instance.collection('forum_posts').where('topic', isEqualTo: _selectedTopicFilter).orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Lỗi tải bài viết: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            final allPosts = snapshot.data?.docs ?? [];
            final posts = allPosts.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final content = (data['content'] ?? "").toString().toLowerCase();
              final author = (data['authorName'] ?? "").toString().toLowerCase();
              return content.contains(_searchText) || author.contains(_searchText);
            }).toList();

            if (posts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Text(
                      _searchText.isEmpty
                          ? "Chưa có bài viết nào. Hãy là người đầu tiên đăng bài!"
                          : "Không tìm thấy bài viết nào phù hợp.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                return _buildPostCard(posts[index].id, post);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreatePostDialog, backgroundColor: kPrimaryBlue, child: const Icon(Icons.edit, color: Colors.white)),
    );
  }

  Widget _buildPostCard(String postId, Map<String, dynamic> post) {
    final DateTime date = (post['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final String formattedDate = DateFormat('HH:mm dd/MM/yyyy').format(date);
    final user = FirebaseAuth.instance.currentUser;
    final List likes = post['likes'] ?? [];
    final bool isLiked = user != null && likes.contains(user.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryBlue.withOpacity(0.1), 
                child: Text(
                  _getAvatarInitial(post['authorName']), 
                  style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold)
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      (post['authorName'] != null && post['authorName'].toString().trim().isNotEmpty) 
                          ? post['authorName'] 
                          : "Người dùng", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ), 
                    Row(
                      children: [
                        Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        if (post['topic'] != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: kPrimaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(post['topic'], style: const TextStyle(color: kPrimaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ]
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post['content'], style: const TextStyle(fontSize: 15, height: 1.5)),

          // ĐÃ SỬA: Bẫy điều kiện hiển thị ảnh bài viết an toàn hơn
          if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                )
              )
            ),

          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(icon: isLiked ? Icons.favorite : Icons.favorite_border, label: "${likes.length}", color: isLiked ? Colors.red : Colors.grey, onTap: () => _toggleLike(postId, isLiked)),
              _buildActionButton(icon: Icons.chat_bubble_outline, label: "${post['commentCount'] ?? 0}", color: Colors.grey, onTap: () => _showComments(postId, post)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))]));
  }

  Future<void> _toggleLike(String postId, bool isLiked) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('forum_posts').doc(postId);
    isLiked ? await ref.update({'likes': FieldValue.arrayRemove([user.uid])}) : await ref.update({'likes': FieldValue.arrayUnion([user.uid])});
  }

  void _showComments(String postId, Map<String, dynamic> post) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => PostDetailScreen(postId: postId, post: post)));
  }
}

// ==========================================================
// MÀN HÌNH CHI TIẾT BÀI VIẾT & BÌNH LUẬN
// ==========================================================
class PostDetailScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.postId, required this.post});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToAuthorName;
  File? _commentImageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện ảnh'),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                  maxWidth: 1080,
                );
                if (pickedFile != null) setState(() => _commentImageFile = File(pickedFile.path));
              }
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                  maxWidth: 1080,
                );
                if (pickedFile != null) setState(() => _commentImageFile = File(pickedFile.path));
              }
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final content = _commentController.text.trim();
    if (content.isEmpty && _commentImageFile == null) return;

    if (!mounted) return;
    setState(() => _isUploading = true);

    try {
      // Upload ảnh và lấy tên chạy song song — KHÔNG thêm .timeout() bên ngoài
      // vì _uploadImage đã có timeout 30s bên trong rồi
      String? url;
      String authorName;

      final imageResult = _commentImageFile != null
          ? await _uploadImage(_commentImageFile!)
          : null;
      url = imageResult;
      authorName = await _getAuthorName(user);

      final commentRef = FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.postId)
          .collection('comments')
          .doc();

      await commentRef.set({
        'authorId': user.uid,
        'authorName': authorName,
        'content': content,
        'imageUrl': url,
        'parentId': _replyToCommentId,
        'replyToName': _replyToAuthorName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Dùng update thay vì set+merge để tránh ghi đè toàn bộ document
      await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.postId)
          .update({'commentCount': FieldValue.increment(1)});

      if (mounted) {
        setState(() {
          _commentController.clear();
          _commentImageFile = null;
          _replyToCommentId = null;
          _replyToAuthorName = null;
          _isUploading = false; // ← reset ngay trong setState này
        });
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi bình luận!"), duration: Duration(seconds: 2))
        );
      }
    } catch (e) {
      print("Lỗi gửi bình luận: $e");
      if (mounted) {
        setState(() => _isUploading = false); // ← reset trong catch
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể gửi bình luận, thử lại.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Bình luận"), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black87),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Sử dụng StreamBuilder để cập nhật số lượng like/comment real-time
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('forum_posts')
                      .doc(widget.postId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Ưu tiên data từ stream, chỉ fallback về widget.post khi chưa có gì
                    final postData = (snapshot.hasData && snapshot.data!.exists)
                        ? snapshot.data!.data() as Map<String, dynamic>
                        : widget.post; // ← fallback tạm thời khi đang load
                    return SliverToBoxAdapter(child: _buildPostHeader(postData));
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('forum_posts').doc(widget.postId).collection('comments').orderBy('timestamp', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Lỗi tải bình luận: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
                    final comments = snapshot.data!.docs;
                    return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                      final comment = comments[index].data() as Map<String, dynamic>;
                      return _buildCommentTile(comments[index].id, comment);
                    }, childCount: comments.length));
                  },
                ),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryBlue.withOpacity(0.1),
                child: Text(_getAvatarInitial(post['authorName']), style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold))
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (post['authorName'] != null && post['authorName'].toString().trim().isNotEmpty)
                        ? post['authorName']
                        : "Người dùng",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  Text(
                    "${post['commentCount'] ?? 0} bình luận",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              )
            ]
          ),
          const SizedBox(height: 12),
          Text(post['content'] ?? "", style: const TextStyle(fontSize: 16)),
          if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['imageUrl'],
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                )
              )
            ),
          const SizedBox(height: 16),
          const Divider(),
          const Text("Tất cả bình luận", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyToAuthorName != null) Row(children: [Text("Đang trả lời $_replyToAuthorName", style: const TextStyle(fontSize: 12, color: Colors.grey)), const Spacer(), IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() { _replyToCommentId = null; _replyToAuthorName = null; }))]),
            if (_commentImageFile != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_commentImageFile!, height: 80)), Positioned(right: 0, child: GestureDetector(onTap: () => setState(() => _commentImageFile = null), child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white))))])),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.image_outlined, color: Colors.grey), onPressed: _pickImage),
                Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Viết bình luận...", border: InputBorder.none))),
                IconButton(icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, color: kPrimaryBlue), onPressed: _isUploading ? null : _submitComment),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(String id, Map<String, dynamic> comment) {
    final bool isReply = comment['parentId'] != null;
    return Container(
      padding: EdgeInsets.only(left: isReply ? 48 : 16, right: 16, top: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18, 
            child: Text(_getAvatarInitial(comment['authorName']))
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            (comment['authorName'] != null && comment['authorName'].toString().trim().isNotEmpty)
                                ? comment['authorName']
                                : "Người dùng", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                          ), 
                          if (comment['replyToName'] != null) ...[
                            const Icon(Icons.arrow_right, size: 16, color: Colors.grey), 
                            Text(comment['replyToName'], style: const TextStyle(color: kPrimaryBlue, fontSize: 12, fontWeight: FontWeight.bold))
                          ]
                        ]
                      ),
                      const SizedBox(height: 4),
                      Text(comment['content'] ?? ""),

                      // ĐÃ SỬA: Kiểm tra an toàn cho ảnh nằm trong bình luận
                      if (comment['imageUrl'] != null && comment['imageUrl'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              comment['imageUrl'],
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            )
                          )
                        ),
                    ],
                  ),
                ),
                TextButton(onPressed: () => setState(() { _replyToCommentId = id; _replyToAuthorName = comment['authorName']; }), child: const Text("Trả lời", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
