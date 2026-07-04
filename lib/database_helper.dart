import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "GuardianDB.db";
  static const _databaseVersion = 3; 
  
  static const table = 'health_records';
  static const chatTable = 'chat_messages';

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
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL,
            screen_time INTEGER NOT NULL,
            sleep_time REAL NOT NULL,
            step_goal INTEGER NOT NULL,
            screen_limit INTEGER NOT NULL,
            screen_min REAL NOT NULL DEFAULT 2.0,
            sleep_min REAL NOT NULL,
            sleep_max REAL NOT NULL
          )
          ''');
          
    await db.execute('''
          CREATE TABLE $chatTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isBot INTEGER NOT NULL,
            text TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $table ADD COLUMN step_goal INTEGER DEFAULT 4000");
      await db.execute("ALTER TABLE $table ADD COLUMN screen_limit INTEGER DEFAULT 7");
      await db.execute("ALTER TABLE $table ADD COLUMN sleep_min REAL DEFAULT 6.0");
      await db.execute("ALTER TABLE $table ADD COLUMN sleep_max REAL DEFAULT 9.0");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE $table ADD COLUMN screen_min REAL DEFAULT 2.0");
    }
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
    await db.delete(chatTable);
    return await db.delete(table);
  }

  Future<int> insertChat(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(chatTable, row);
  }

  Future<List<Map<String, dynamic>>> readAllChats() async {
    Database db = await instance.database;
    return await db.query(chatTable, orderBy: "timestamp ASC"); 
  }

  Future<void> saveSummaryAndClearChats(String summary, String timestamp) async {
    Database db = await instance.database;
    await db.delete(chatTable, where: 'isBot IN (0, 1)');
    await db.insert(chatTable, {
      'isBot': 2,
      'text': summary,
      'timestamp': timestamp
    });
  }
}