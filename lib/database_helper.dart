import 'package:sqflite/sqflite.dart';
import 'srs_logic.dart';
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

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  // Xử lý nâng cấp DB khi thêm cột mới
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE vocabulary ADD COLUMN image_path TEXT');
    }
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
        image_path TEXT, -- Cột mới để lưu đường dẫn ảnh phân cấp
        is_mastered INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE grammar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        structure TEXT NOT NULL,
        usage TEXT NOT NULL,
        example TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE srs_data (
        vocab_id INTEGER PRIMARY KEY,
        next_review_date TEXT NOT NULL, 
        interval INTEGER DEFAULT 0,
        ease_factor REAL DEFAULT 2.5
      )
    ''');
  }

  // --- HÀM NẠP DỮ LIỆU THẬT VỚI ĐƯỜNG DẪN ẢNH PHÂN CẤP ---
  Future<void> insertN5Data() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> n5List = [
      {
        'word': '猫', 
        'reading': 'Neko', 
        'meaning': 'Con mèo', 
        'level': 'N5',
        'image_path': 'assets/images/N5/example_neko.png' // Ảnh nằm trong folder N5
      },
      {
        'word': '車', 
        'reading': 'Kuruma', 
        'meaning': 'Xe ô tô', 
        'level': 'N5',
        'image_path': 'assets/images/N5/example_kuruma.png'
      },
    ];

    final batch = db.batch();
    for (var item in n5List) {
      batch.insert('vocabulary', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertN4Data() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> n4List = [
      {
        'word': '海', 
        'reading': 'Umi', 
        'meaning': 'Biển', 
        'level': 'N4',
        'image_path': 'assets/images/N4/example_umi.png' // Ảnh nằm trong folder N4
      },
    ];

    final batch = db.batch();
    for (var item in n4List) {
      batch.insert('vocabulary', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // --- TRUY VẤN ---
  Future<List<Map<String, dynamic>>> getVocabByLevel(String level) async {
    final db = await instance.database;
    return await db.query('vocabulary', where: 'level = ?', whereArgs: [level]);
  }

  Future<void> updateVocabSrs(int vocabId, int quality) async {
    final db = await instance.database;
    final data = await db.query('srs_data', where: 'vocab_id = ?', whereArgs: [vocabId]);
    
    int interval = data.isEmpty ? 0 : data.first['interval'] as int;
    double easeFactor = data.isEmpty ? 2.5 : data.first['ease_factor'] as double;

    final result = SrsLogic.calculateNextReview(interval, easeFactor, quality);
    final nextDate = DateTime.now().add(Duration(days: result['interval'])).toIso8601String().split('T')[0];

    await db.insert(
      'srs_data',
      {
        'vocab_id': vocabId,
        'next_review_date': nextDate,
        'interval': result['interval'],
        'ease_factor': result['easeFactor']
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
