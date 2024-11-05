import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/chat_message_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the database if it's not already created
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            msgtext TEXT,
            userid TEXT,
            isme INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertMessage(MessageData message) async {
    final db = await database;
    log("message is this ${message.msgtext}");
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MessageData>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages');

    return List.generate(maps.length, (i) {
      return MessageData.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }
}
