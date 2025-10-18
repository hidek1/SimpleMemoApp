import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'memo_sample_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        category TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  // --- notes テーブル用メソッド ---

  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'created_at DESC');
  }

  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await database;
    return await db.update('notes', note, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- categories テーブル用メソッド ---

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'id ASC');
  }

  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update('categories', category, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // 初期データ挿入（テスト用）
  Future<void> insertInitialData() async {
    final db = await database;
    
    // カテゴリの初期データ
    final categories = [
      {'name': '生活'},
      {'name': '仕事'},
      {'name': '学習'},
      {'name': 'その他'},
    ];
    
    for (final category in categories) {
      await db.insert('categories', category);
    }
    
    // メモの初期データ
    final now = DateTime.now();
    final notes = [
      {
        'title': '買い物リスト',
        'content': '牛乳、たまご、パン、バター、野菜',
        'category': '生活',
        'is_favorite': 0,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'title': 'プロジェクト会議メモ',
        'content': '来週の会議は水曜日10時\n議題：新機能の仕様検討',
        'category': '仕事',
        'is_favorite': 1,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': 'Flutter学習メモ',
        'content': 'StatefulWidgetの使い方\nsetState()でUI更新',
        'category': '学習',
        'is_favorite': 1,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'title': '旅行の準備',
        'content': 'パスポート確認\nホテル予約\n飛行機チケット',
        'category': 'その他',
        'is_favorite': 0,
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'title': '読書メモ',
        'content': '『Clean Code』を読了\n重要なポイント：\n- 関数は小さく\n- 意味のある名前',
        'category': '学習',
        'is_favorite': 0,
        'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 6)).toIso8601String(),
      },
    ];
    
    for (final note in notes) {
      await db.insert('notes', note);
    }
  }

  // データベースが空かチェック
  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final noteCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM notes')) ?? 0;
    final categoryCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories')) ?? 0;
    return noteCount == 0 && categoryCount == 0;
  }
}
