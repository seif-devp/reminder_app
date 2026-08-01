import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("medication_app.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT,
        gender TEXT,
        age TEXT,
        blood_type TEXT,
        weight REAL,
        height REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        med_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT,
        dosage TEXT,
        frequency TEXT,
        duration_of_use TEXT,
        start_date TEXT,
        end_date TEXT,
        notes TEXT,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medication_schedule (
        schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
        med_id INTEGER,
        intake_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE intake_records (
        record_id INTEGER PRIMARY KEY AUTOINCREMENT,
        med_id INTEGER,
        taken_at TEXT,
        status TEXT
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
