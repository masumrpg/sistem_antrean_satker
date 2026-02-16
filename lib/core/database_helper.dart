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
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
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
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'IN',
        out_at TEXT,
        taker_name TEXT,
        taker_satker TEXT
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE antrian ADD COLUMN status TEXT DEFAULT 'IN'",
      );
      await db.execute("ALTER TABLE antrian ADD COLUMN out_at TEXT");
      await db.execute("ALTER TABLE antrian ADD COLUMN taker_name TEXT");
      await db.execute("ALTER TABLE antrian ADD COLUMN taker_satker TEXT");
    }
  }

  // --- Antrian CRUD ---

  Future<int> insertAntrian(Map<String, dynamic> antrian) async {
    final db = await database;
    return await db.insert('antrian', antrian);
  }

  Future<int> deleteAllAntrian() async {
    final db = await database;
    return await db.delete('antrian');
  }

  Future<Map<String, dynamic>?> getAntrianByFD(
    int nomorFD, {
    DateTime? date,
  }) async {
    final db = await database;
    final searchDate = date ?? DateTime.now();
    final results = await db.query(
      'antrian',
      where: 'nomor_fd = ? AND date(created_at) = date(?)',
      whereArgs: [nomorFD, searchDate.toIso8601String()],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateAntrianStatus(
    int nomorFD,
    DateTime recordDate,
    String status,
    DateTime outAt,
    String takerName,
    String takerSatker,
  ) async {
    final db = await database;
    final dateStr = recordDate.toIso8601String().substring(0, 10);

    // Find that day's 'IN' record with this FD
    final List<Map<String, dynamic>> maps = await db.query(
      'antrian',
      where: 'nomor_fd = ? AND created_at LIKE ? AND status = ?',
      whereArgs: [nomorFD, '$dateStr%', 'IN'],
    );

    if (maps.isEmpty) {
      return 0; // Not found or already OUT
    }

    final id = maps.first['id'] as int;
    return await db.update(
      'antrian',
      {
        'status': status,
        'out_at': outAt.toIso8601String(),
        'taker_name': takerName,
        'taker_satker': takerSatker,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<List<Map<String, dynamic>>> getAntrianByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    return await db.query(
      'antrian',
      where: "created_at LIKE ?",
      whereArgs: ['$dateStr%'],
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
