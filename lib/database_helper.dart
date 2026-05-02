import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "GuardianDB.db";
  static const _databaseVersion = 1;
  static const table = 'health_records';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL,
            screen_time INTEGER NOT NULL,
            sleep_time REAL NOT NULL
          )
          ''');
  }

  Future<int> insertRecord(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> readAllRecords() async {
    Database db = await instance.database;
    return await db.query(table, orderBy: "date DESC");
  }

  Future<int> deleteAllRecords() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
  
}