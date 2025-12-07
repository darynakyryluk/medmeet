import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user_model.dart';
import 'visit_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medilog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        doctorName TEXT NOT NULL,
        specialty TEXT NOT NULL,
        date TEXT NOT NULL,
        diagnosis TEXT,
        notes TEXT,
        price REAL DEFAULT 0,
        isCompleted INTEGER DEFAULT 0,
        tags TEXT DEFAULT '',
        category TEXT DEFAULT 'Плановий',
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      
      try {
        await db.execute("ALTER TABLE visits ADD COLUMN tags TEXT DEFAULT '';");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE visits ADD COLUMN category TEXT DEFAULT 'Плановий';");
      } catch (_) {}
    }
  }

  
  Future<int> registerUser(User user) async {
    final db = await instance.database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<bool> checkUserExists(String username) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return maps.isNotEmpty;
  }

  Future<int> updatePassword(String username, String newPassword) async {
    final db = await instance.database;
    return await db.update('users', {'password': newPassword}, where: 'username = ?', whereArgs: [username]);
  }

  Future<int> deleteAccount(int userId) async {
    final db = await instance.database;
    
    return await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  
  Future<int> createVisit(Visit visit) async {
    final db = await instance.database;
    return await db.insert('visits', visit.toMap());
  }

  Future<int> updateVisit(Visit visit) async {
    final db = await instance.database;
    return await db.update('visits', visit.toMap(), where: 'id = ?', whereArgs: [visit.id]);
  }

  Future<int> deleteVisit(int id) async {
    final db = await instance.database;
    return await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Visit>> getVisits(int userId) async {
    final db = await instance.database;
    final res = await db.query('visits', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return res.map((m) => Visit.fromMap(m)).toList();
  }

  Future<List<Visit>> searchVisits(int userId, String q) async {
    final db = await instance.database;
    final like = '%${q.toLowerCase()}%';
    final res = await db.rawQuery('''
      SELECT * FROM visits WHERE userId = ? AND (
        lower(doctorName) LIKE ? OR lower(specialty) LIKE ? OR lower(tags) LIKE ? OR lower(diagnosis) LIKE ?
      ) ORDER BY date DESC
    ''', [userId, like, like, like, like]);
    return res.map((m) => Visit.fromMap(m)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
