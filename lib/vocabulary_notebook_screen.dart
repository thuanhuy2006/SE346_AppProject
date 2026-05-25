import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'sound_manager.dart';

class VocabularyNotebookScreen extends StatefulWidget {
  const VocabularyNotebookScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyNotebookScreen> createState() => _VocabularyNotebookScreenState();
}

class _VocabularyNotebookScreenState extends State<VocabularyNotebookScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await DatabaseHelper.instance.getAllBookmarks();
    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  Future<void> _removeBookmark(String jpWord) async {
    await DatabaseHelper.instance.removeBookmark(jpWord);
    _loadBookmarks(); // Refresh list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa khỏi sổ tay!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ tay từ vựng'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final item = _bookmarks[index];
                    return _buildBookmarkItem(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Sổ tay của bạn đang trống!',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy nhấn biểu tượng 🔖 trong bài học\nđể lưu lại những từ khó nhé.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
            onPressed: () {
              SoundManager.instance.speakJapanese(item['jp_word']);
            },
          ),
        ),
        title: Text(
          item['jp_word'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['romaji'] != null && item['romaji'].toString().isNotEmpty)
              Text(
                item['romaji'],
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 4),
            Text(
              item['meaning'],
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
          onPressed: () => _removeBookmark(item['jp_word']),
          tooltip: 'Xóa khỏi sổ tay',
        ),
      ),
    );
  }
}
