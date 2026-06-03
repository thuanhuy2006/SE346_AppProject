import 'package:flutter/material.dart';
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
            labelColor: Color(0xFFFF5252), // Màu đỏ cho phần nghe
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
    // Giả lập 5 bài nghe cho mỗi cấp độ
    final List<Map<String, String>> lessons = List.generate(5, (index) {
      return {
        'title': 'Bài nghe $level - Số ${index + 1}',
        'topic': _getTopic(index),
        'duration': "${(index + 2) * 1} phút",
      };
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
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
                if (level == "N5" && index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListeningDetailScreen(
                        title: lesson['title']!,
                        audioAsset: 'assets/audio/listening_n5_1.mp3',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tính năng nghe ${lesson['title']} đang được phát triển!")),
                  );
                }
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
                            lesson['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Chủ đề: ${lesson['topic']}",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          _buildTag(lesson['duration']!, Colors.blueGrey),
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

  String _getTopic(int index) {
    final topics = ["Hội thoại hằng ngày", "Tại nhà ga", "Trong cửa hàng", "Thời tiết", "Thông báo công cộng"];
    return topics[index % topics.length];
  }
}
