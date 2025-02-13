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

  DatabaseHelper._init() {
    init();
  }

  // Initialisation de la base de données (SQLite ou Hive selon la plateforme)
  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter(); // Initialisation pour Web
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit(); // Initialisation pour les plateformes de bureau
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Accéder à la base de données SQLite
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemon_battle.db');
    return _database!;
  }

  // Initialisation de la base de données SQLite
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Vérifier si la base de données existe déjà
    final exists = await databaseFactory.databaseExists(path);
    if (exists) {
      print("La base de données existe déjà, ouverture...");
      return await databaseFactory.openDatabase(path);
    } else {
      print("Création de la base de données...");
      return await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(version: 1, onCreate: _createDB));
    }
  }

// Création des tables dans la base de données SQLite
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
        username TEXT,  -- Stocke directement le username au lieu de user_id
        result TEXT,
        user_team TEXT,
        opponent_team TEXT,
        date TEXT,
        FOREIGN KEY (username) REFERENCES accounts (username) ON DELETE CASCADE
      )
    ''');
  }

  // Insérer un compte dans la base de données SQLite ou Hive
  Future<void> insertAccount(String username, String password) async {
    if (kIsWeb) {
      var box = await Hive.openBox('accounts');
      await box.put(username, {'username': username, 'password': password});
    } else {
      final db = await database;
      await db.insert('accounts', {
        'username': username,
        'password': password,
      });
    }
  }

  Future<void> insertBattle(String username, String result, String userTeam, String opponentTeam) async {
    if (kIsWeb) {
      var box = await Hive.openBox('battle_history');
      await box.add({
        'username': username,
        'result': result,
        'user_team': userTeam,
        'opponent_team': opponentTeam,
        'date': DateTime.now().toIso8601String(),
      });
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

  // Méthode pour récupérer un utilisateur par son nom d'utilisateur (SQLite ou Hive)
  Future<Map<String, dynamic>?> getUser(String username) async {
    if (kIsWeb) {
      var box = await Hive.openBox('accounts');

      var user = box.get(username);
      if (user != null) {
        return Map<String, dynamic>.from(user);
      }
      return null;
    } else {
      final db = await database;
      final result = await db.query(
        'accounts',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty ? result.first : null;
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


  // Récupérer l'historique des batailles avec le username
  Future<List<Map<String, dynamic>>> getBattleHistory() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT b.*, a.username
    FROM battle_history b
    JOIN accounts a ON b.username = a.username
    ''');
    return result;
  }


  // Vérifier si un utilisateur existe dans la base de données
  Future<bool> doesUserExist(String username) async {
    if (kIsWeb) {
      var box = await Hive.openBox('accounts');
      return box.containsKey(username);
    } else {
      final db = await database;
      final result = await db.query(
        'accounts',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    }
  }

  // Méthode pour récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (kIsWeb) {
      var box = await Hive.openBox('accounts');
      return box.values.toList().cast<Map<String, dynamic>>();
    } else {
      final db = await database;
      return await db.query('accounts');
    }
  }
}