import 'package:flutter/material.dart';

class AlphabetPracticeListScreen extends StatelessWidget {
  const AlphabetPracticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập cho danh sách các bài luyện tập
    final List<Map<String, String>> practiceItems = [
      {'title': 'Luyện tập 1', 'details': 'あ・い・う・え・お\nア・イ・ウ・エ・オ'},
      {'title': 'Luyện tập 2', 'details': 'か・き・く・け・こ\nカ・キ・ク・ケ・コ'},
      {'title': 'Luyện tập 3', 'details': 'さ・し・す・せ・そ\nサ・シ・ス・セ・ソ'},
      {'title': 'Luyện tập 4', 'details': 'た・ち・つ・て・と\nタ・チ・ツ・テ・ト'},
      {'title': 'Luyện tập 5', 'details': 'な・に・ぬ・ね・の\nナ・ニ・ヌ・ネ・ノ'},
      {'title': 'Luyện tập 6', 'details': 'は・ひ・ふ・へ・ほ\nハ・ヒ・フ・へ・ホ'},
      {'title': 'Luyện tập 7', 'details': 'ま・み・む・め・も・や・ゆ・よ\nマ・ミ・ム・メ・モ・ヤ・ユ・ヨ'},
      {'title': 'Luyện tập 8', 'details': 'ら・り・る・れ・ろ・わ・を・ん\nラ・リ・ル・レ・ロ・ワ・ヲ・ン'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng chữ cái'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: practiceItems.length,
        itemBuilder: (context, index) {
          final item = practiceItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Biểu tượng cuốn sách màu xanh lá cây
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FDF5), // Màu xanh lá cây rất nhạt
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.book_outlined,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Tiêu đề và nội dung ký tự
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        item['details']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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