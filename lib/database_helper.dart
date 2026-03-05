import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kanji_summoner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kanji (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character TEXT NOT NULL,
        meaning TEXT NOT NULL,
        strokes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vocabulary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        reading TEXT NOT NULL,
        meaning TEXT NOT NULL,
        level TEXT NOT NULL,
        is_mastered INTEGER DEFAULT 0 -- 0: Chưa thuộc, 1: Đã thuộc
      )
    ''');

    // 3. Bảng Grammar (Trận pháp)
    await db.execute('''
      CREATE TABLE grammar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        structure TEXT NOT NULL,
        usage TEXT NOT NULL,
        example TEXT
      )
    ''');

    print("DB Created with 3 Tables!");
  }

  // --- HÀM TRIỆU HỒI (INSERT DATA) ---
  Future<void> insertDummyData() async {
    final db = await instance.database;

    // Thêm thử 1 con Kanji: Hỏa
    await db.insert('kanji', {
      'character': '火',
      'meaning': 'Lửa (Fire)',
      'strokes': '4'
    });

    // Thêm thử 1 con Quái thú (Từ vựng): Mèo
    await db.insert('vocabulary', {
      'word': '猫',
      'reading': 'Neko',
      'meaning': 'Con mèo',
      'level': 'N5',
      'is_mastered': 0
    });

    print("Đã triệu hồi dữ liệu mẫu!");
  }

  // --- HÀM TRIỆU HỒI QUÂN ĐOÀN N5 (Nạp dữ liệu thật) ---
  Future<void> insertN5Data() async {
    final db = await instance.database;

    // Danh sách 20 Kanji N5 cơ bản nhất (Thiên nhiên & Con người)
    final List<Map<String, dynamic>> n5List = [
      {'word': '日', 'reading': 'Hi / Nichi', 'meaning': 'Mặt trời / Ngày', 'level': 'N5'},
      {'word': '月', 'reading': 'Tsuki / Gatsu', 'meaning': 'Mặt trăng / Tháng', 'level': 'N5'},
      {'word': '木', 'reading': 'Ki / Moku', 'meaning': 'Cây cối', 'level': 'N5'},
      {'word': '山', 'reading': 'Yama / San', 'meaning': 'Núi', 'level': 'N5'},
      {'word': '川', 'reading': 'Kawa / Sen', 'meaning': 'Sông', 'level': 'N5'},
      {'word': '田', 'reading': 'Ta / Den', 'meaning': 'Ruộng lúa', 'level': 'N5'},
      {'word': '人', 'reading': 'Hito / Jin', 'meaning': 'Con người', 'level': 'N5'},
      {'word': '口', 'reading': 'Kuchi / Kou', 'meaning': 'Cái miệng', 'level': 'N5'},
      {'word': '車', 'reading': 'Kuruma / Sha', 'meaning': 'Xe ô tô', 'level': 'N5'},
      {'word': '門', 'reading': 'Mon', 'meaning': 'Cổng', 'level': 'N5'},
      {'word': '火', 'reading': 'Hi / Ka', 'meaning': 'Lửa', 'level': 'N5'},
      {'word': '水', 'reading': 'Mizu / Sui', 'meaning': 'Nước', 'level': 'N5'},
      {'word': '金', 'reading': 'Kane / Kin', 'meaning': 'Tiền / Vàng', 'level': 'N5'},
      {'word': '土', 'reading': 'Tsuchi / Do', 'meaning': 'Đất', 'level': 'N5'},
      {'word': '子', 'reading': 'Ko / Shi', 'meaning': 'Trẻ con', 'level': 'N5'},
      {'word': '女', 'reading': 'Onna / Jo', 'meaning': 'Phụ nữ', 'level': 'N5'},
      {'word': '学', 'reading': 'Manabu / Gaku', 'meaning': 'Học', 'level': 'N5'},
      {'word': '生', 'reading': 'Ikiru / Sei', 'meaning': 'Sống / Sinh ra', 'level': 'N5'},
      {'word': '先', 'reading': 'Saki / Sen', 'meaning': 'Trước / Tiên', 'level': 'N5'},
      {'word': '私', 'reading': 'Watashi', 'meaning': 'Tôi', 'level': 'N5'},
    ];

    // Dùng Batch để insert một lúc cho nhanh (tối ưu hiệu năng)
    final batch = db.batch();

    for (var item in n5List) {
      // Kiểm tra xem từ này đã có chưa để tránh trùng lặp
      final existing = await db.query(
          'vocabulary',
          where: 'word = ?',
          whereArgs: [item['word']]
      );

      if (existing.isEmpty) {
        batch.insert('vocabulary', {
          'word': item['word'],
          'reading': item['reading'],
          'meaning': item['meaning'],
          'level': item['level'],
          'is_mastered': 0 // Mặc định là chưa thuộc
        });
      }
    }

    await batch.commit(noResult: true);
    print("Đã triệu hồi quân đoàn N5!");
  }

  // Hàm xóa sạch dữ liệu (để reset game nếu cần)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('vocabulary');
  }

  // --- HÀM TRUY VẤN (GET DATA) ---
  Future<List<Map<String, dynamic>>> getAllVocab() async {
    final db = await instance.database;
    return await db.query('vocabulary');
  }

  Future<void> markAsMastered(int id) async {
    final db = await instance.database;
    await db.update(
      'vocabulary',
      {'is_mastered': 1}, // Đánh dấu là đã thuộc
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- HÀM ĐẾM SỐ QUÁI ĐÃ THU PHỤC (Để tính Level cho Pet) ---
  Future<int> getMasteredCount() async {
    final db = await instance.database;
    var result = await db.rawQuery('SELECT COUNT(*) FROM vocabulary WHERE is_mastered = 1');
    int? count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }
}