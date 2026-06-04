import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listening_detail_screen.dart';

class ListeningPracticeScreen extends StatelessWidget {
  const ListeningPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Luyện nghe tiếng Nhật",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: false,
            labelColor: Color(0xFFFF5252),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF5252),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "N5"),
              Tab(text: "N4"),
              Tab(text: "N3"),
              Tab(text: "N2"),
              Tab(text: "N1"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LevelListeningList(level: "N5"),
            LevelListeningList(level: "N4"),
            LevelListeningList(level: "N3"),
            LevelListeningList(level: "N2"),
            LevelListeningList(level: "N1"),
          ],
        ),
      ),
    );
  }
}

class LevelListeningList extends StatelessWidget {
  final String level;
  const LevelListeningList({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Đọc thời gian thực danh sách bài tập dựa trên cấp độ JLPT
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listening_lessons')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)));
        }

        // Lọc danh sách bài theo cấp độ (Ví dụ: Tiêu đề chứa chữ "N5" hoặc "N4")
        final allDocs = snapshot.data?.docs ?? [];
        final filteredLessons = allDocs.where((doc) {
          final title = (doc.data() as Map<String, dynamic>)['title']?.toString() ?? '';
          return title.toLowerCase().contains(level.toLowerCase());
        }).toList();

        if (filteredLessons.isEmpty) {
          return Center(
            child: Text(
              "Chưa có dữ liệu bài nghe cấp độ $level",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredLessons.length,
          itemBuilder: (context, index) {
            final docData = filteredLessons[index].data() as Map<String, dynamic>;
            final String title = docData['title'] ?? 'Bài nghe không tên';
            final String audioAsset = docData['audioAsset'] ?? '';

            // Định dạng hiển thị chủ đề linh hoạt
            final topics = ["Hội thoại hằng ngày", "Tại nhà ga", "Trong cửa hàng", "Thời tiết", "Thông báo công cộng"];
            final String currentTopic = topics[index % topics.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListeningDetailScreen(
                          title: title,
                          lessonId: docData['id'],
                          audioAsset: audioAsset.isNotEmpty ? audioAsset : 'assets/audio/listening_n5_1.mp3',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.headphones, color: Color(0xFFFF5252), size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Chủ đề: $currentTopic",
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Đề thi chính thức",
                                  style: TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_circle_fill, size: 30, color: Color(0xFFFF5252)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}