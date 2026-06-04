import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_progress.dart';

class ListeningDetailScreen extends StatefulWidget {
  final String title;
  final String lessonId;
  final String audioAsset;
  const ListeningDetailScreen({
    super.key,
    required this.title,
    required this.lessonId,
    required this.audioAsset,
  });

  @override
  State<ListeningDetailScreen> createState() => _ListeningDetailScreenState();
}

class _ListeningDetailScreenState extends State<ListeningDetailScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  bool _showAllAnswers = false;
  double _playbackSpeed = 1.0;

  // Khởi tạo danh sách câu hỏi rỗng để nạp động từ Admin/Firestore hoặc dùng mặc định
  final List<Map<String, dynamic>> _questions = [];
  String _audioTextScript = ""; // Lưu văn bản hội thoại đọc từ Admin
  bool _isLoadingFirestore = false;
  String _activeAudioAsset = "";

  @override
  void initState() {
    super.initState();
    _activeAudioAsset = widget.audioAsset;
    _initializeListeningLesson();
  }

  Future<void> _initializeListeningLesson() async {
    setState(() => _isLoadingFirestore = true);
    try {
      final String listenDocId = widget.lessonId;
      final lessonDoc = await FirebaseFirestore.instance.collection('listening_lessons').doc(listenDocId).get();
      if (lessonDoc.exists) {
        final lessonData = lessonDoc.data();
        if (lessonData != null) {
          if (lessonData['audioAsset'] != null && lessonData['audioAsset'].toString().isNotEmpty) {
            _activeAudioAsset = lessonData['audioAsset'];
          }
          if (lessonData['audio_text'] != null) {
            _audioTextScript = lessonData['audio_text'];
          }
        }
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('listening_lessons')
          .doc(listenDocId)
          .collection('questions')
          .orderBy('id')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> tempQuestions = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          tempQuestions.add({
            'id': data['id'] ?? 1,
            'question': data['question'], // Hỗ trợ text câu hỏi nếu có
            'q_image': data['q_image'] != null && data['q_image'].toString().isNotEmpty ? data['q_image'] : null,
            'options': List<String>.from(data['options'] ?? []),
            'correct': data['correct'] ?? 'A',
            'explanation': data['explanation'] ?? '',
          });
        }
        tempQuestions.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

        setState(() {
          _questions.clear();
          _questions.addAll(tempQuestions);
        });
      } else {
        setState(() {
        _questions.clear();
      });
    }
  } catch (e) {
        print("Lỗi tải câu hỏi nghe từ Firestore: $e");
        _loadDefaultQuestions();
  }

    final isNetwork = _activeAudioAsset.startsWith('http') || _activeAudioAsset.startsWith('https');
    _controller = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(_activeAudioAsset))
        : VideoPlayerController.asset(_activeAudioAsset);

    _controller.initialize().then((_) {
      _controller.setPlaybackSpeed(_playbackSpeed);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoadingFirestore = false;
        });
      }
    }).catchError((e) {
      print("Lỗi khởi tạo audio player: $e");
      if (mounted) {
        setState(() => _isLoadingFirestore = false);
      }
    });
  }

  void _loadDefaultQuestions() {
    _questions.addAll([
      {'id': 1, 'q_image': 'assets/images/n5_l1_q1.png', 'options': ["A. 1", "B. 2", "C. 3", "D. 4"], 'correct': "B", 'explanation': "Dựa vào nội dung nghe, nhân vật đang nói về môn thể thao Bowling (Hình 1)."},
      {'id': 2, 'q_image': 'assets/images/n5_l1_q2.png', 'options': ["A. 1", "B. 2", "C. 3", "D. 4"], 'correct': "D", 'explanation': "Người đàn ông tặng một bó hoa lớn cho người phụ nữ (Hình 3)."},
      {'id': 3, 'q_image': 'assets/images/n5_l1_q3.png', 'options': ["A. 1", "B. 2", "C. 3", "D. 4"], 'correct': "D", 'explanation': "Người phụ nữ đi mua sắm tại siêu thị (Hình 2)."},
      {'id': 4, 'q_image': 'assets/images/n5_l1_q4.png', 'options': ["A. 1", "B. 2", "C. 3", "D. 4"], 'correct': "A", 'explanation': "Bố trí phòng họp theo sơ đồ hình tam giác (Hình 4)."},
      {'id': 5, 'options': ["A. 1. 43215018", "B. 2. 43215078", "C. 3. 42315018", "D. 4. 42315078"], 'correct': "D", 'explanation': "Số điện thoại chính xác được đọc trong đoạn băng là 4321-5078."},
      {'id': 6, 'options': ["A. 1. 3じ", "B. 2. 4じ", "C. 3. 5じ", "D. 4. 6じ"], 'correct': "C", 'explanation': "Nhân vật chốt thời gian gặp mặt là 5 giờ (5じ)."},
      {'id': 7, 'options': ["A. 1. 7じから", "B. 2. シャワーをあびてから", "C. 3. しんぶんをよんでから", "D. 4. しょっきuをあらってから"], 'correct': "D", 'explanation': "Theo lịch trình, hành động tiếp theo sẽ bắt đầu từ lúc 7 giờ (7じから)."},
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_userAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa trả lời hết các câu hỏi!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận nộp bài"),
        content: const Text("Bạn có chắc chắn muốn nộp bài nghe này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isSubmitted = true;
                _showAllAnswers = true;
                _controller.pause();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã nộp bài! Kéo xuống để xem giải thích và hội thoại thoại (Script).")),
              );
            },
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFirestore) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5252))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAudioPlayer(),
            const SizedBox(height: 30),

            // TIÊU ĐỀ HƯỚNG DẪN CHUNG
            const Text(
              "もんだい：しつもんを聞いてください。それからはなしを聞いて、1から4の中から、ただしいこたえをひとつえらんでください。",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Divider(),

            // HIỂN THỊ SCRIPT ĐOẠN VĂN NGHE (CHỈ HIỆN KHI ĐÃ NỘP BÀI)
            if (_showAllAnswers && _audioTextScript.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Văn bản nghe (Script Hội thoại):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_audioTextScript, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                  ],
                ),
              ),
            ],

            // DANH SÁCH CÂU HỎI AN TOÀN (DÙNG MAP THAY VÌ SUBLIST CỐ ĐỊNH ĐỂ TRÁNH CRASH)
            ..._questions.map((q) => _buildQuestionBlock(q)),

            const SizedBox(height: 40),

            if (!_isSubmitted)
              _buildLargeButton("NỘP BÀI", const Color(0xFFFF5252), _handleSubmit)
            else
              _buildLargeButton("KẾT THÚC XEM LẠI", Colors.orange, () async {
                int score = 0;
                for (var q in _questions) {
                  if (_userAnswers[q['id']] == q['correct']) score++;
                }
                await UserProgress().addExp(score * 5);
                if (mounted) {
                  // Hiển thị thông báo tổng số câu đúng trực quan
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Chúc mừng! Bạn làm đúng $score/${_questions.length} câu. Nhận được ${score * 5} EXP!")),
                  );
                  Navigator.pop(context);
                }
              }),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const Icon(Icons.headset, size: 50, color: Color(0xFFFF5252)),
          const SizedBox(height: 16),
          if (_isInitialized) ...[
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                return Column(
                  children: [
                    Slider(
                      activeColor: const Color(0xFFFF5252),
                      inactiveColor: Colors.grey[200],
                      value: value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: value.duration.inMilliseconds.toDouble(),
                      onChanged: (val) {
                        _controller.seekTo(Duration(milliseconds: val.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(value.position), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_formatDuration(value.duration), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: _playbackSpeed,
                      icon: const Icon(Icons.speed, color: Color(0xFFFF5252), size: 16),
                      style: const TextStyle(color: Color(0xFFFF5252), fontSize: 13, fontWeight: FontWeight.bold),
                      onChanged: (double? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _playbackSpeed = newValue;
                            _controller.setPlaybackSpeed(newValue);
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 0.5, child: Text("0.5x")),
                        DropdownMenuItem(value: 0.75, child: Text("0.75x")),
                        DropdownMenuItem(value: 1.0, child: Text("1.0x")),
                        DropdownMenuItem(value: 1.25, child: Text("1.25x")),
                        DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 30),
                  onPressed: () {
                    final newPos = _controller.value.position - const Duration(seconds: 10);
                    _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 30),
                  onPressed: () {
                    final newPos = _controller.value.position + const Duration(seconds: 10);
                    _controller.seekTo(newPos);
                  },
                ),
              ],
            ),
          ] else
            const CircularProgressIndicator(color: Color(0xFFFF5252)),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildQuestionBlock(Map<String, dynamic> q) {
      bool isInstruction = q['options'] == null || (q['options'] as List).isEmpty;

      if (isInstruction) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.only(top: 20),
          child: Text(
            q['question'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        );
      }

      // Giao diện vẽ câu hỏi trắc nghiệm bình thường (Hỗ trợ cả câu có ảnh và câu thuần chữ)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text("Câu ${q['id']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (q['question'] != null && q['question'].toString().trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(q['question'], style: const TextStyle(fontSize: 15, color: Colors.black87)),
            ),

          // Chỉ hiển thị khối ảnh nếu câu đó được Admin chọn ảnh minh họa
          if (q['q_image'] != null && q['q_image'].toString().trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: q['q_image'].toString().startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(q['q_image'], fit: BoxFit.contain, errorBuilder: (c, e, s) => const SizedBox()),
                    )
                  : Image.asset(q['q_image'], errorBuilder: (c, e, s) => const SizedBox()),
            ),
          const SizedBox(height: 8),
          // Vẽ danh sách đáp án bo góc (Đảm bảo các câu thuần chữ ở Ảnh 2 & 4 hiển thị cực kỳ đẹp mắt)
          ...(q['options'] as List).map((opt) => _buildOption(q['id'], opt, q['correct'])),
          if (_showAllAnswers) _buildExplanationBox(q['correct'], q['explanation']),
          const Divider(height: 30),
        ],
      );
    }

  Widget _buildOption(int questionId, String text, String correctLetter) {
    String letter = text.substring(0, 1);
    bool isSelected = _userAnswers[questionId] == letter;
    bool isCorrect = letter == correctLetter;

    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;

    if (isSelected) {
      borderColor = const Color(0xFFFF5252);
      bgColor = const Color(0xFFFFEBEE);
    }

    if (_showAllAnswers) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!_isSubmitted) {
          setState(() => _userAnswers[questionId] = letter);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
            if (_showAllAnswers && isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (_showAllAnswers && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationBox(String correct, String explanation) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Đáp án đúng: $correct", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Text(explanation, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildLargeButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}