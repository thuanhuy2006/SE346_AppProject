import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import 'sound_manager.dart';
import 'main.dart';

class VocabularyNotebookScreen extends StatefulWidget {
  const VocabularyNotebookScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyNotebookScreen> createState() => _VocabularyNotebookScreenState();
}

class _VocabularyNotebookScreenState extends State<VocabularyNotebookScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  Set<String> _bookmarkedWords = {};
  bool _isLoading = true;

  // Lọc danh mục: 'all', 'vocabulary', 'grammar', 'tip'
  String _selectedFilter = 'all';

  // Khám phá dữ liệu
  List<Map<String, dynamic>> _popularItems = [];
  bool _isLoadingPopular = true;

  // Danh sách bí kíp từ vựng tự biên soạn
  final List<Map<String, String>> _curatedTips = [
    {
      'jp_word': 'Vô thanh hóa nguyên âm',
      'romaji': 'Mẹo phát âm',
      'meaning': 'Đối với các câu kết thúc bằng 「〜です」 hay 「〜ます」 thì nguyên âm "u" trong chữ 「す su」 bị vô âm hóa. Vì vậy khi phát âm 「です」 sẽ giống như bạn nói "dess" hay "mass" vậy.',
      'type': 'tip',
    },
    {
      'jp_word': 'Nhớ Kanji bộ HỎA (火)',
      'romaji': 'Mẹo nhớ chữ Hán',
      'meaning': 'Bộ Hỏa (火) tượng trưng cho ngọn lửa bùng cháy. Khi ghép thành các từ như pháo hoa (花火 - hanabi), bạn sẽ thấy sự rực rỡ của hoa lửa!',
      'type': 'tip',
    },
    {
      'jp_word': 'Ý nghĩa chữ MÈO (猫)',
      'romaji': 'Mẹo từ vựng thú vị',
      'meaning': 'Chữ Hán 猫 (Mèo) gồm bộ KHUYỂN (chó/thú nhỏ) bên trái và bộ ĐIỀN (ruộng) bên phải, tượng trưng cho loài thú nhỏ chuyên bắt chuột bảo vệ ruộng lúa.',
      'type': 'tip',
    },
    {
      'jp_word': 'Quy tắc âm ngắt (っ)',
      'romaji': 'Mẹo phát âm',
      'meaning': 'Khi gặp âm ngắt っ (tsu nhỏ), hãy gấp đôi phụ âm đứng ngay sau nó. Ví dụ: きっぷ (kipp-o: vé), đọc nhấn mạnh phụ âm "p".',
      'type': 'tip',
    },
    {
      'jp_word': 'Cách chào Konnichiwa & Konbanwa',
      'romaji': 'Mẹo giao tiếp',
      'meaning': '「こんにちは」 chào ban ngày (11h - 17h). Sau 18h tối hãy chuyển sang 「こんばんは」 để thể hiện sự lịch thiệp nhé.',
      'type': 'tip',
    },
    {
      'jp_word': 'Phân biệt Ageru & Kureru',
      'romaji': 'Mẹo ngữ pháp',
      'meaning': 'Cả hai đều có nghĩa là "cho/tặng", nhưng あげる (ageru) dùng khi mình tặng người khác, còn くれる (kureru) dùng khi người khác tặng cho mình.',
      'type': 'tip',
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _loadPopularItems();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await DatabaseHelper.instance.getAllBookmarks();
    if (mounted) {
      setState(() {
        _bookmarks = bookmarks;
        _bookmarkedWords = bookmarks.map((b) => b['jp_word'] as String).toSet();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPopularItems() async {
    if (mounted) {
      setState(() => _isLoadingPopular = true);
    }
    List<Map<String, dynamic>> items = [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('global_bookmarks')
          .orderBy('saved_count', descending: true)
          .limit(20)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        int count = data['saved_count'] ?? 0;
        // Chỉ hiện những từ được lưu phổ biến (saved_count >= 2)
        if (count >= 2) {
          items.add({
            'jp_word': data['jp_word'] ?? doc.id,
            'romaji': data['romaji'] ?? '',
            'meaning': data['meaning'] ?? '',
            'type': data['type'] ?? 'vocabulary',
            'saved_count': count,
          });
        }
      }
    } catch (e) {
      print("Lỗi tải popular bookmarks từ Firestore: $e");
    }

    // Kết hợp dữ liệu hạt giống (seed) nếu danh sách trống hoặc quá ngắn
    if (items.length < 3) {
      final List<Map<String, dynamic>> seedItems = [
        {'jp_word': '猫', 'romaji': 'Neko', 'meaning': 'Con mèo', 'type': 'vocabulary', 'saved_count': 142},
        {'jp_word': '火', 'romaji': 'Hi / Ka', 'meaning': 'Lửa', 'type': 'vocabulary', 'saved_count': 95},
        {'jp_word': '山', 'romaji': 'Yama / San', 'meaning': 'Núi', 'type': 'vocabulary', 'saved_count': 88},
        {'jp_word': '水', 'romaji': 'Mizu / Sui', 'meaning': 'Nước', 'type': 'vocabulary', 'saved_count': 76},
        {'jp_word': '～てください', 'romaji': '-te kudasai', 'meaning': 'Hãy làm việc gì đó (Cầu khiến lịch sự)', 'type': 'grammar', 'saved_count': 104},
        {'jp_word': '人', 'romaji': 'Hito / Jin', 'meaning': 'Con người', 'type': 'vocabulary', 'saved_count': 64},
      ];

      for (var seed in seedItems) {
        if (!items.any((x) => x['jp_word'] == seed['jp_word'])) {
          items.add(seed);
        }
      }
    }

    // Sắp xếp theo saved_count giảm dần
    items.sort((a, b) => (b['saved_count'] as int).compareTo(a['saved_count'] as int));

    if (mounted) {
      setState(() {
        _popularItems = items;
        _isLoadingPopular = false;
      });
    }
  }

  Future<void> _removeBookmark(String jpWord) async {
    await DatabaseHelper.instance.removeBookmark(jpWord);
    await _loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa khỏi sổ tay!')),
      );
    }
  }

  Future<void> _toggleBookmarkFromExplore(Map<String, dynamic> item) async {
    final jpWord = item['jp_word'];
    final isSaved = _bookmarkedWords.contains(jpWord);

    if (isSaved) {
      await DatabaseHelper.instance.removeBookmark(jpWord);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa "$jpWord" khỏi sổ tay!')),
        );
      }
    } else {
      await DatabaseHelper.instance.addBookmark(
        jpWord,
        item['romaji'] ?? '',
        item['meaning'] ?? '',
        type: item['type'] ?? 'vocabulary',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu "$jpWord" vào sổ tay!')),
        );
      }
    }
    await _loadBookmarks();
    _loadPopularItems();
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        final String typeText = item['type'] == 'tip'
            ? 'Bí kíp'
            : (item['type'] == 'grammar' ? 'Ngữ pháp' : 'Từ vựng');
        final Color typeColor = item['type'] == 'tip'
            ? Colors.orange
            : (item['type'] == 'grammar' ? Colors.green : Colors.blueAccent);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  typeText,
                  style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['jp_word'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item['romaji'] != null && item['romaji'].toString().isNotEmpty) ...[
                Text(
                  item['romaji'],
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 16),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                item['meaning'],
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            if (item['type'] == 'vocabulary')
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                onPressed: () {
                  SoundManager.instance.speakJapanese(item['jp_word']);
                },
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kSoftBackground,
        appBar: AppBar(
          title: const Text(
            'Sổ tay của bạn',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
          backgroundColor: kSoftBackground,
          foregroundColor: Colors.black87,
          elevation: 0,
          iconTheme: const IconThemeData(color: kPrimaryBlue),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const TabBar(
                labelColor: kPrimaryBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: kPrimaryBlue,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: [
                  Tab(text: 'Sổ tay của tôi'),
                  Tab(text: 'Khám phá'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyNotebookTab(),
            _buildExploreTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: SỔ TAY CỦA TÔI ---
  Widget _buildMyNotebookTab() {
    // Lọc danh sách theo filter chip
    List<Map<String, dynamic>> filteredList = _bookmarks.where((item) {
      if (_selectedFilter == 'all') return true;
      return (item['type'] ?? 'vocabulary') == _selectedFilter;
    }).toList();

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildNotebookCard(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Tất cả', 'value': 'all'},
      {'label': 'Từ vựng', 'value': 'vocabulary'},
      {'label': 'Ngữ pháp', 'value': 'grammar'},
      {'label': 'Bí kíp', 'value': 'tip'},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: kPrimaryBlue,
              backgroundColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade200,
                width: 1,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter['value']!;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Danh mục này đang trống!',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Hãy nhấn biểu tượng 🔖 trong quá trình học tập\nhoặc vào tab Khám phá để lưu nội dung hay nhé!'
                  : 'Không có dữ liệu thuộc thể loại này trong sổ tay của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotebookCard(Map<String, dynamic> item) {
    final String type = item['type'] ?? 'vocabulary';
    IconData leadingIcon = Icons.volume_up;
    Color leadingBg = Colors.blue.shade50;
    Color iconColor = Colors.blueAccent;

    if (type == 'grammar') {
      leadingIcon = Icons.menu_book_rounded;
      leadingBg = Colors.green.shade50;
      iconColor = Colors.green;
    } else if (type == 'tip') {
      leadingIcon = Icons.lightbulb_outline_rounded;
      leadingBg = Colors.orange.shade50;
      iconColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetailDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Avatar / Audio Button
              GestureDetector(
                onTap: () {
                  if (type == 'vocabulary') {
                    SoundManager.instance.speakJapanese(item['jp_word']);
                  } else {
                    _showDetailDialog(item);
                  }
                },
                child: CircleAvatar(
                  backgroundColor: leadingBg,
                  radius: 24,
                  child: Icon(leadingIcon, color: iconColor),
                ),
              ),
              const SizedBox(width: 16),
              // Column 2: Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['jp_word'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge hiển thị loại
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: leadingBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type == 'tip' ? 'Bí kíp' : (type == 'grammar' ? 'Ngữ pháp' : 'Từ vựng'),
                            style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item['romaji'] != null && item['romaji'].toString().isNotEmpty) ...[
                      Text(
                        item['romaji'],
                        style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      item['meaning'],
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Column 3: Delete Action
              IconButton(
                icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
                onPressed: () => _removeBookmark(item['jp_word']),
                tooltip: 'Xóa khỏi sổ tay',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: KHÁM PHÁ (EXPLORE) ---
  Widget _buildExploreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần 1: Bí kíp học từ vựng (Curated Tips)
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text(
                'Bí kíp học từ vựng hay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _curatedTips.length,
              itemBuilder: (context, index) {
                final tip = _curatedTips[index];
                final isSaved = _bookmarkedWords.contains(tip['jp_word']);

                // Phối màu gradient nhẹ cho card bí kíp
                final gradients = [
                  [Colors.orange.shade300, Colors.deepOrange.shade400],
                  [Colors.purple.shade300, Colors.indigo.shade400],
                  [Colors.teal.shade300, Colors.green.shade400],
                  [Colors.blue.shade300, Colors.indigo.shade500],
                ];
                final gradient = gradients[index % gradients.length];

                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 14, bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tip['jp_word']!,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: () => _toggleBookmarkFromExplore(tip),
                          )
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tip['romaji']!,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          tip['meaning']!,
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Phần 2: Nội dung học được nhiều người lưu (Popular items)
          Row(
            children: [
              const Icon(Icons.whatshot, color: Colors.redAccent),
              const SizedBox(width: 8),
              const Text(
                'Lưu phổ biến nhất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Spacer(),
              if (_isLoadingPopular)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                  onPressed: _loadPopularItems,
                )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Những từ vựng và nội dung được nhiều người học lưu lại nhiều nhất gần đây.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularItems.length,
            itemBuilder: (context, index) {
              final item = _popularItems[index];
              final jpWord = item['jp_word'];
              final isSaved = _bookmarkedWords.contains(jpWord);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Text(
                        jpWord,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (item['romaji'] != null && item['romaji'].isNotEmpty)
                        Text(
                          '(${item['romaji']})',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['meaning'], style: const TextStyle(color: Colors.black87)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.whatshot, size: 12, color: Colors.redAccent),
                              const SizedBox(width: 2),
                              Text(
                                '${item['saved_count']} lượt lưu',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => _toggleBookmarkFromExplore(item),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
