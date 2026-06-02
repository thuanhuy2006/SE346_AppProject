import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_progress.dart';
import 'database_helper.dart';
import 'achievements_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  final ValueNotifier<int> activeTabNotifier;
  const LeaderboardScreen({super.key, required this.activeTabNotifier});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _userExp = 0;
  String _userName = 'Người chơi';
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _leaderboardUsers = [];
  List<Map<String, dynamic>> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.activeTabNotifier.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.activeTabNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (widget.activeTabNotifier.value == 2) {
      _loadData();
    }
  }

  Future<void> _cleanupMockDatabaseData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      bool hasDeletes = false;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String name = (data['name'] ?? '').toString().toLowerCase();
        final String email = (data['email'] ?? '').toString().toLowerCase();
        final int exp = data['exp'] ?? 0;

        bool shouldDelete = false;
        if (name.contains('test') || email.contains('test')) {
          shouldDelete = true;
        } else if (name == 'người chơi' && exp == 0) {
          shouldDelete = true;
        } else if (name.isEmpty && email.isEmpty) {
          shouldDelete = true;
        }

        if (shouldDelete) {
          batch.delete(doc.reference);
          hasDeletes = true;
        }
      }

      if (hasDeletes) {
        await batch.commit();
        print("Đã dọn dẹp các tài khoản thử nghiệm trên server.");
      }
    } catch (e) {
      print("Lỗi khi dọn dẹp dữ liệu thử nghiệm: $e");
    }
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      // 1. Tải dữ liệu cục bộ song song để tăng tốc
      final results = await Future.wait([
        UserProgress().getExp(),
        UserProgress().getCompletedLessons(),
        DatabaseHelper.instance.getMasteredCount(),
      ]);

      final exp = results[0] as int;
      final completed = results[1] as List<String>;
      final masteredCount = results[2] as int;
      final user = FirebaseAuth.instance.currentUser;

      String currentUserName = 'Người chơi';
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          currentUserName = user.displayName!;
        } else if (user.email != null) {
          currentUserName = user.email!.split('@').first;
        }
      }

      final calculatedAchievements = AchievementData.getCalculatedList(
        exp: exp,
        completedLessons: completed,
        masteredCount: masteredCount,
      );

      if (mounted) {
        setState(() {
          _userExp = exp;
          _userName = currentUserName;
          _achievements = calculatedAchievements;
        });
      }

      // 2. Tải danh sách xếp hạng từ Firestore
      // Bỏ qua _cleanupMockDatabaseData() ở đây vì nó làm chậm quá trình load UI

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('exp', isGreaterThan: 0)
          .orderBy('exp', descending: true)
          .limit(50)
          .get();

      final List<Map<String, dynamic>> fetchedUsers = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        bool isMe = user != null && doc.id == user.uid;
        
        fetchedUsers.add({
          'name': data['name'] ?? 'Người chơi',
          'exp': data['exp'] ?? 0,
          'isMe': isMe,
        });
      }

      // Đảm bảo người dùng hiện tại luôn có trong danh sách kể cả khi rớt top (dùng dữ liệu local)
      if (user != null && !fetchedUsers.any((u) => u['isMe'] == true)) {
        fetchedUsers.add({
          'name': _userName,
          'exp': _userExp,
          'isMe': true,
        });
        // Sắp xếp lại
        fetchedUsers.sort((a, b) => (b['exp'] as int).compareTo(a['exp'] as int));
      }

      if (mounted) {
        setState(() {
          _leaderboardUsers = fetchedUsers;
        });
      }

      // Đồng bộ EXP lên background, không bắt người dùng đợi
      if (user != null && exp > 0) {
         UserProgress().addExp(0);
      }

    } catch (e) {
      print("Lỗi tải bảng xếp hạng: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRankName(int exp) {
    final List<String> ranks = [
      "Tân binh", "Binh nhất", "Thượng sĩ", "Đại uý", "Đại tá", "Đại tướng",
    ];
    final List<int> expThresholds = [0, 50, 150, 300, 600, 1000];
    int currentRankIndex = 0;
    for (int i = 0; i < expThresholds.length; i++) {
      if (exp >= expThresholds[i]) {
        currentRankIndex = i;
      } else {
        break;
      }
    }
    return currentRankIndex < ranks.length ? ranks[currentRankIndex] : ranks.last;
  }

  @override
  Widget build(BuildContext context) {
    // Lấy cấp bậc hiện tại
    String userRank = _getRankName(_userExp);

    // Lấy danh hiệu đã mở khóa
    final achievements = _achievements.where((a) => (a['progress'] as double) >= 1.0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          "Xếp hạng & Thành tựu", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(silent: true),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thẻ thông tin cá nhân (Thành tựu)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 5),
                                  Text("$_userName đã đạt bậc $userRank", style: const TextStyle(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (achievements.isNotEmpty)
                          Text(
                            "$_userName vừa đạt: ${achievements.last['title']}!", 
                            style: const TextStyle(fontSize: 14, color: Colors.white, fontStyle: FontStyle.italic)
                          )
                        else
                          const Text(
                            "Hãy học tập để mở khóa nhiều thành tựu nhé!", 
                            style: TextStyle(fontSize: 14, color: Colors.white, fontStyle: FontStyle.italic)
                          ),
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text("Bảng Xếp Hạng Top 50", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  
                  if (_leaderboardUsers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Chưa có dữ liệu xếp hạng trên máy chủ.", style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                  // Danh sách xếp hạng
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _leaderboardUsers.length,
                    itemBuilder: (context, index) {
                      final user = _leaderboardUsers[index];
                      final isMe = user['isMe'] == true;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: isMe ? Border.all(color: Colors.blueAccent, width: 2) : null,
                          boxShadow: [
                            if (!isMe) const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: index == 0 ? Colors.amber : (index == 1 ? Colors.grey.shade400 : (index == 2 ? Colors.brown.shade300 : Colors.blue.shade100)),
                            child: Text(
                              "#${index + 1}",
                              style: TextStyle(color: index < 3 ? Colors.white : Colors.blue.shade800, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(user['name'], style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
                          trailing: Text("${user['exp']} EXP", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      ),
    );
  }
}
