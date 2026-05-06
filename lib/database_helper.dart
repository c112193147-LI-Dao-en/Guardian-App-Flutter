import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "GuardianDB.db";
  static const _databaseVersion = 1;
  
  static const table = 'health_records';
  static const chatTable = 'chat_messages'; // 👉 新增：聊天紀錄資料表

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
    // 原本的健康數據表
    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL,
            screen_time INTEGER NOT NULL,
            sleep_time REAL NOT NULL
          )
          ''');
          
    // 👉 新增：創立聊天紀錄表
    await db.execute('''
          CREATE TABLE $chatTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isBot INTEGER NOT NULL,
            text TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
          ''');
  }

  // --- 原本的健康數據方法 ---
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

  // --- 👉 新增的聊天紀錄方法 ---
  Future<int> insertChat(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(chatTable, row);
  }
  Future<List<Map<String, dynamic>>> readAllChats() async {
    Database db = await instance.database;
    // 聊天紀錄通常是越舊的在越上面 (ASC)
    return await db.query(chatTable, orderBy: "timestamp ASC"); 
  }
}