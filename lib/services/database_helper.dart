import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static late BoxCollection _hiveCollection;

  DatabaseHelper._init() {
    init();
  }

  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
      _hiveCollection = await BoxCollection.open(
        'pokemon_battle_db',
        {'accounts', 'battle_history'},
        path: '.',
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemon_battle.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE battle_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        result TEXT,
        user_team TEXT,
        opponent_team TEXT,
        date TEXT,
        FOREIGN KEY (username) REFERENCES accounts (username) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertAccount(String username, String password) async {
    if (kIsWeb) {
      var accountsBox = await _hiveCollection.openBox('accounts');
      await accountsBox.put(username, {'username': username, 'password': password});
    } else {
      final db = await database;
      await db.insert('accounts', {'username': username, 'password': password});
    }
  }

  // Récupérer un utilisateur par son ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertBattle(String username, String result, String userTeam, String opponentTeam) async {
    if (kIsWeb) {
      var battleBox = await _hiveCollection.openBox('battle_history');

      await battleBox.put(DateTime.now().toIso8601String(),{
        'username': username,
        'result': result,
        'user_team': userTeam,
        'opponent_team': opponentTeam,
        'date': DateTime.now().toIso8601String(),
      });

      var savedBattle = await battleBox.get(DateTime.now().toIso8601String());

    } else {
      final db = await database;
      await db.insert('battle_history', {
        'username': username,
        'result': result,
        'user_team': userTeam,
        'opponent_team': opponentTeam,
        'date': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    if (kIsWeb) {
      var accountsBox = await _hiveCollection.openBox('accounts');
      var user = await accountsBox.get(username);
      return user != null ? Map<String, dynamic>.from(user) : null;
    } else {
      final db = await database;
      final result = await db.query('accounts', where: 'username = ?', whereArgs: [username]);
      return result.isNotEmpty ? result.first : null;
    }
  }

  Future<List<Map<String, dynamic>>> getBattleHistory() async {
    if (kIsWeb) {
      var battleBox = await _hiveCollection.openBox('battle_history');
      final battleData = await battleBox.getAllValues();

      return battleData.values.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      final db = await database;
      return await db.query('battle_history');
    }
  }

  Future<bool> doesUserExist(String username) async {
    if (kIsWeb) {
      var accountsBox = await _hiveCollection.openBox('accounts');
      return await accountsBox.get(username) != null;
    } else {
      final db = await database;
      final result = await db.query('accounts', where: 'username = ?', whereArgs: [username]);
      return result.isNotEmpty;
    }
  }
}
