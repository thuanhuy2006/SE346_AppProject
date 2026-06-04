import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reading_detail_screen.dart';

class ReadingPracticeScreen extends StatelessWidget {
  const ReadingPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Luyện đọc tiếng Nhật",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: false,
            labelColor: Color(0xFF3366FF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF3366FF),
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
            LevelReadingList(level: "N5"),
            LevelReadingList(level: "N4"),
            LevelReadingList(level: "N3"),
            LevelReadingList(level: "N2"),
            LevelReadingList(level: "N1"),
          ],
        ),
      ),
    );
  }
}

class LevelReadingList extends StatelessWidget {
  final String level;
  const LevelReadingList({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reading_lessons')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3366FF)));
        }

        final allDocs = snapshot.data?.docs ?? [];
        // Lọc bài đọc hiển thị theo Tab cấp độ tương ứng
        final filteredLessons = allDocs.where((doc) {
          final title = (doc.data() as Map<String, dynamic>)['title']?.toString() ?? '';
          return title.toLowerCase().contains(level.toLowerCase());
        }).toList();

        if (filteredLessons.isEmpty) {
          return Center(
            child: Text(
              "Chưa có dữ liệu bài đọc cấp độ $level",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredLessons.length,
          itemBuilder: (context, index) {
            final docData = filteredLessons[index].data() as Map<String, dynamic>;
            final String title = docData['title'] ?? 'Bài đọc không tên';

            final topics = ["Gia đình", "Trường học", "Công việc", "Du lịch", "Văn hóa"];
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
                        builder: (context) => ReadingDetailScreen(
                          title: title,
                          lessonIndex: 1, // Mặc định chuyển sang nạp cấu trúc từ Firestore
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
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.menu_book, color: Color(0xFF3366FF), size: 30),
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
                              Row(
                                children: [
                                  _buildTag(_getDifficulty(level), Colors.orange),
                                  const SizedBox(width: 8),
                                  _buildTag("Luyện đọc hiểu", Colors.blueGrey),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getDifficulty(String level) {
    if (level == "N5") return "Dễ";
    if (level == "N4") return "Trung bình";
    if (level == "N3") return "Khá";
    if (level == "N2") return "Khó";
    return "Rất khó";
  }
}