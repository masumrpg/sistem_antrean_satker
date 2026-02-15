import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final appDir = await getApplicationSupportDirectory();
    final dbPath = p.join(appDir.path, 'antrean_satker.db');

    return await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE antrian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        sub_satker TEXT NOT NULL,
        nomor_fd INTEGER NOT NULL,
        durasi INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Set initial FD number
    await db.insert('settings', {'key': 'last_fd_number', 'value': '0'});
  }

  // --- Antrian CRUD ---

  Future<int> insertAntrian(Map<String, dynamic> antrian) async {
    final db = await database;
    return await db.insert('antrian', antrian);
  }

  Future<List<Map<String, dynamic>>> getAllAntrian() async {
    final db = await database;
    return await db.query('antrian', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getAntrianToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.query(
      'antrian',
      where: "created_at LIKE ?",
      whereArgs: ['$today%'],
      orderBy: 'id DESC',
    );
  }

  // --- Settings ---

  Future<int> getLastFDNumber() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: "key = ?",
      whereArgs: ['last_fd_number'],
    );
    if (result.isNotEmpty) {
      return int.parse(result.first['value'] as String);
    }
    return 0;
  }

  Future<void> saveLastFDNumber(int number) async {
    final db = await database;
    await db.update(
      'settings',
      {'value': number.toString()},
      where: "key = ?",
      whereArgs: ['last_fd_number'],
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: "key = ?",
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
