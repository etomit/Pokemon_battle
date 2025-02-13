import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  String? get username => _username;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    notifyListeners();
  }

  Future<bool> signup(String username, String password) async {
    final dbHelper = DatabaseHelper.instance;
    final existingUser = await dbHelper.getUser(username);

    if (existingUser != null) {
      return false;
    }
    await dbHelper.insertAccount(username, password);
    return true;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {

    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUser(username);

    if (user != null) {
      if (user['password'] == password) {
        _username = user['username'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _username!); // Stocke le username au lieu de l'ID
        notifyListeners();
        return user;
      } else {
        print('Mot de passe incorrect');
      }
    } else {
      print('Utilisateur non trouvé');
    }

    return null; // Si la connexion échoue
  }

  void logout() async {
    _username = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username'); // Suppression du username de SharedPreferences
    notifyListeners();
  }
}