import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        regNo TEXT,
        password TEXT,
        school TEXT,
        department TEXT,
        year TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        message TEXT,
        file TEXT,
        school TEXT,
        department TEXT,
        year TEXT,
        senderRole TEXT,
        createdAt TEXT
      );
    ''');
  }

  Future<void> registerStudent(String regNo, String password, String school, String dept, String year) async {
    final db = await instance.database;
    await db.insert('students', {
      'regNo': regNo,
      'password': password,
      'school': school,
      'department': dept,
      'year': year,
    });
  }

  Future<Map<String, dynamic>?> getStudent(String regNo, String password) async {
    final db = await instance.database;
    final result = await db.query('students',
        where: 'regNo = ? AND password = ?', whereArgs: [regNo, password]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> sendMessage({
    required String title,
    required String msg,
    required String file,
    required String school,
    required String dept,
    required String year,
    required String role,
  }) async {
    final db = await instance.database;
    await db.insert('messages', {
      'title': title,
      'message': msg,
      'file': file,
      'school': school,
      'department': dept,
      'year': year,
      'senderRole': role,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMessagesForStudent(String school, String dept, String year) async {
    final db = await instance.database;
    return await db.query(
      'messages',
      where: 'school = ? AND department = ? AND year = ?',
      whereArgs: [school, dept, year],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllMessages() async {
    final db = await instance.database;
    return await db.query('messages', orderBy: 'createdAt DESC');
  }

  Future<void> deleteMessage(int id) async {
    final db = await instance.database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateMessage(int id, String title, String message, String file) async {
    final db = await instance.database;
    await db.update('messages', {
      'title': title,
      'message': message,
      'file': file,
    }, where: 'id = ?', whereArgs: [id]);
  }
}
