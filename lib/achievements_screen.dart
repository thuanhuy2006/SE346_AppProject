import 'package:flutter/material.dart';

// ==========================================================
// 1. KHO DỮ LIỆU CHUNG (Class này bắt buộc phải có để main.dart gọi được)
// ==========================================================
class AchievementData {
  static final List<Map<String, dynamic>> list = [
    {'title': 'Tân binh nhập môn', 'desc': 'Hoàn thành bài học đầu tiên', 'icon': Icons.school, 'color': Colors.blue, 'progress': 1.0},
    {'title': 'Cún chăm chỉ', 'desc': 'Đăng nhập liên tiếp 7 ngày', 'icon': Icons.calendar_month, 'color': Colors.teal, 'progress': 0.7},
    {'title': 'Xạ thủ tập sự', 'desc': 'Đúng 10 câu liên tiếp trong 1 bài', 'icon': Icons.gps_fixed, 'color': Colors.redAccent, 'progress': 0.5},
    {'title': 'Bá chủ Hiragana', 'desc': 'Hoàn thành toàn bộ bảng Hiragana', 'icon': Icons.translate, 'color': Colors.purple, 'progress': 0.3},
    {'title': 'Katakana Master', 'desc': 'Hoàn thành toàn bộ bảng Katakana', 'icon': Icons.language, 'color': Colors.deepPurple, 'progress': 0.0},
    {'title': 'Cú đêm', 'desc': 'Hoàn thành bài học sau 12h đêm', 'icon': Icons.nightlight_round, 'color': Colors.indigo, 'progress': 0.0},
    {'title': 'Dậy sớm để thành công', 'desc': 'Hoàn thành bài học trước 6h sáng', 'icon': Icons.wb_sunny, 'color': Colors.orange, 'progress': 0.0},
    {'title': 'Tốc độ ánh sáng', 'desc': 'Hoàn thành bài học trong dưới 1 phút', 'icon': Icons.flash_on, 'color': Colors.yellow[700], 'progress': 0.0},
    {'title': 'Không lùi bước', 'desc': 'Sai 5 câu liên tiếp nhưng vẫn hoàn thành bài', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.grey, 'progress': 0.0},
    {'title': 'Vua từ vựng', 'desc': 'Học thuộc 50 từ vựng mới', 'icon': Icons.menu_book, 'color': Colors.green, 'progress': 0.2},
    {'title': 'Thánh ngữ pháp', 'desc': 'Hoàn thành 10 bài ngữ pháp', 'icon': Icons.spellcheck, 'color': Colors.brown, 'progress': 0.0},
    {'title': 'Đôi tai vàng', 'desc': 'Đạt điểm tuyệt đối bài nghe hiểu', 'icon': Icons.hearing, 'color': Colors.cyan, 'progress': 0.0},
    {'title': 'Kanji Đại chiến', 'desc': 'Học xong 100 chữ Kanji N5', 'icon': Icons.edit_note, 'color': Colors.deepOrange, 'progress': 0.1},
    {'title': 'Triệu phú EXP', 'desc': 'Đạt tổng cộng 1000 EXP', 'icon': Icons.bolt, 'color': Colors.amber, 'progress': 0.13},
    {'title': 'Bạn thân quốc dân', 'desc': 'Kết bạn với 5 người dùng khác', 'icon': Icons.group_add, 'color': Colors.pink, 'progress': 0.0},
    {'title': 'Kẻ hủy diệt bài tập', 'desc': 'Làm xong 50 bài luyện tập', 'icon': Icons.fitness_center, 'color': Colors.black87, 'progress': 0.05},
    {'title': 'Bất khả chiến bại', 'desc': 'Đạt chuỗi 30 ngày học liên tiếp', 'icon': Icons.local_fire_department, 'color': Colors.red, 'progress': 0.0},
    {'title': 'Nhà thám hiểm', 'desc': 'Mở khóa tất cả các vùng đất', 'icon': Icons.map, 'color': Colors.greenAccent, 'progress': 0.0},
    {'title': 'Học bá', 'desc': 'Đứng top 1 bảng xếp hạng tuần', 'icon': Icons.emoji_events, 'color': Colors.amberAccent, 'progress': 0.0},
    {'title': 'Huyền thoại', 'desc': 'Mở khóa toàn bộ danh hiệu', 'icon': Icons.diamond, 'color': Colors.blueAccent, 'progress': 0.05},
  ];
}

// ==========================================================
// 2. MÀN HÌNH DANH HIỆU CHI TIẾT
// ==========================================================
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 SỬA Ở ĐÂY: Không code cứng danh sách nữa, mà gọi từ AchievementData.list
    final List<Map<String, dynamic>> achievements = AchievementData.list;

    int unlockedCount = achievements.where((e) => e['progress'] >= 1.0).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Danh hiệu", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. HEADER XANH
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF78C850), // Màu xanh lá chuẩn
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/confetti_bg.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bạn đã đạt được", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "$unlockedCount/${achievements.length}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          const TextSpan(text: " Danh hiệu", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                Transform.rotate(
                  angle: 0.2,
                  child: const Icon(Icons.emoji_events, size: 80, color: Colors.amberAccent),
                ),
              ],
            ),
          ),

          // 2. LIST DANH HIỆU
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final item = achievements[index];
                bool isUnlocked = item['progress'] >= 1.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      // Icon bên trái
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          item['icon'],
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Nội dung text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? Colors.black87 : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'],
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 8),

                            // Thanh tiến trình (Sửa lỗi minHeight bằng SizedBox)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 6, // Quy định chiều cao thanh tiến trình
                                child: LinearProgressIndicator(
                                  value: item['progress'] == 0.0 ? 0.02 : item['progress'], // Tránh để trống hoàn toàn
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      isUnlocked ? const Color(0xFF58CC02) : (item['color'] as Color).withOpacity(0.5)
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}