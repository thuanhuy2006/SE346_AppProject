import 'package:flutter/material.dart';

// ==========================================================
// 1. KHO DỮ LIỆU CHUNG CHỨA CÁC MẸO HỌC TẬP
// ==========================================================
class TipsData {
  static final List<Map<String, dynamic>> list = [
    {'id': 1, 'text': 'Đối với các câu kết thúc với 「〜です」 hay 「〜ます」 thì nguyên âm u trong chữ 「す su」 bị vô âm hóa.\nVì vậy, khi phát âm 「です」 sẽ giống như bạn nói "dess" vậy. :-D', 'isLiked': true},
    {'id': 2, 'text': 'かばんがありましたよ。\nỞ đây 「ありました」 biểu thị rằng người nói đã phát hiện rằng đã tìm thấy túi xách, chứ không phải đã có chiếc túi xách ở một thời điểm trong quá khứ.', 'isLiked': true},
    {'id': 3, 'text': '「上がります」thường dùng khi nói về giá cả, tỉ lệ, tiền hay khi giá trị, tính chất của cái gì đó được nâng lên, tăng thêm. Còn 「増えます」thì dùng khi nói về số lượng (VD: dân số) với hàm ý rằng cái gì đó đang gia tăng dần.', 'isLiked': true},
    {'id': 4, 'text': '「こんにちは」—lời chào phổ biến nhất, có thể sử dụng bất cứ lúc nào, tuy nhiên chủ yếu dùng vào ban ngày từ 11 giờ sáng đến 5 giờ chiều', 'isLiked': true},
    {'id': 5, 'text': 'Chữ KATAKANA được dùng để biểu thị tên người hoặc địa danh nước ngoài hoặc các từ ngoại lai.', 'isLiked': true},
    {'id': 6, 'text': '「おはようございます」- lời chào thường được sử dụng trước 12 giờ trưa', 'isLiked': false},
    {'id': 7, 'text': '「こんばんは」- lời chào thường được sử dụng sau khoảng 6 giờ chiều hoặc hoàng hôn', 'isLiked': false},
  ];

  // Hàm tự động sắp xếp: Tim đỏ lên đầu, tim xám xuống cuối
  static void sortTips() {
    list.sort((a, b) {
      if (a['isLiked'] == b['isLiked']) {
        return a['id'].compareTo(b['id']); // Nếu cùng trạng thái tim thì giữ nguyên thứ tự ID
      }
      return a['isLiked'] ? -1 : 1;
    });
  }

  // Hàm xử lý khi bấm thả tim
  static void toggleLike(int id) {
    final tip = list.firstWhere((element) => element['id'] == id);
    tip['isLiked'] = !tip['isLiked'];
    sortTips(); // Sắp xếp lại ngay lập tức bên trong kho dữ liệu
  }
}

// ==========================================================
// 2. MÀN HÌNH DANH SÁCH MẸO CHI TIẾT
// ==========================================================
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  @override
  Widget build(BuildContext context) {
    final tips = TipsData.list;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Mẹo học tiếng Nhật", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    tip['text'],
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                ),
                const SizedBox(width: 15),
                // Nút thả tim ở màn hình chi tiết (Bấm phát tự động nhảy lên đầu luôn)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      TipsData.toggleLike(tip['id']);
                    });
                  },
                  child: Icon(
                    Icons.favorite,
                    color: tip['isLiked'] ? Colors.redAccent : Colors.pink.shade100,
                    size: 28,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}