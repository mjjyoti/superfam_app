import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'key_value.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE key_value(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT, name TEXT)',
        );
      },
    );
  }

  Future<void> insertKeyValue(String key, String value, String name) async {
    final db = await database;
    await db.insert(
      'key_value',
      {'key': key, 'value': value, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getKeyValues() async {
    final db = await database;
    return await db.query('key_value');
  }

  Future<void> deleteKeyValue(int id) async {
    final db = await database;
    await db.delete(
      'key_value',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
