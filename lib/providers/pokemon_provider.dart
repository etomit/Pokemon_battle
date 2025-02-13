import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/database_helper.dart';

class PokemonProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _pokemonDetails;
  List<Map<String, dynamic>> _randomTeam = [];
  List<Map<String, dynamic>> _userTeam = [];
  List<Map<String, dynamic>> _battleHistory = [];
  int? _currentUserId;

  // Getters
  List<Map<String, dynamic>> get pokemonList => _pokemonList;
  Map<String, dynamic>? get pokemonDetails => _pokemonDetails;
  List<Map<String, dynamic>> get randomTeam => _randomTeam;
  List<Map<String, dynamic>> get userTeam => _userTeam;
  List<Map<String, dynamic>> get battleHistory => _battleHistory;
  int? get currentUserId => _currentUserId;

  // Fetch Pokémon list
  Future<void> fetchPokemonList() async {
    final url = "https://tyradex.vercel.app/api/v1/pokemon";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _pokemonList = data.cast<Map<String, dynamic>>();
        notifyListeners();
      }
    } catch (error) {
      print("Erreur lors de la récupération de la liste des Pokémon: $error");
    }
  }

  // Fetch Pokémon details
  Future<void> fetchPokemonDetails(int id) async {
    final url = "https://tyradex.vercel.app/api/v1/pokemon/$id";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _pokemonDetails = json.decode(response.body);
        notifyListeners();
      } else {
        _pokemonDetails = null;
      }
    } catch (error) {
      print("Erreur lors de la récupération des détails: $error");
      _pokemonDetails = null;
    }
  }

  // Générer une équipe aléatoire
  void generateRandomTeam(List<Map<String, dynamic>> allPokemons) {
    _randomTeam.clear();
    final random = Random();
    while (_randomTeam.length < 6) {
      final randomPokemon = allPokemons[random.nextInt(allPokemons.length)];
      if (!_randomTeam.contains(randomPokemon)) {
        _randomTeam.add(randomPokemon);
      }
    }
    notifyListeners();
  }

  void addPokemonToUserTeam(Map<String, dynamic> pokemon) {
    if (_userTeam.length < 6 && !_userTeam.contains(pokemon)) {
      _userTeam.add(pokemon);
      notifyListeners();
    }
  }

  void removePokemonFromUserTeam(Map<String, dynamic> pokemon) {
    _userTeam.remove(pokemon);
    notifyListeners();
  }

  void clearUserTeam() {
    _userTeam.clear();
    notifyListeners();
  }

  Future<void> saveBattleHistory(String result) async {
    final db = DatabaseHelper.instance;
    if (_currentUserId == null) return;

    final user = await db.getUserById(_currentUserId!);
    if (user == null) return;

    String username = user['username'];
    final userTeamJson = json.encode(_userTeam);
    final opponentTeamJson = json.encode(_randomTeam);
    await db.insertBattle(username, result, userTeamJson, opponentTeamJson);

    _battleHistory.add({
      'username': username,
      'result': result,
      'userTeam': _userTeam,
      'opponentTeam': _randomTeam,
      'date': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  // Charger l'historique des batailles depuis la base de données
  Future<void> loadBattleHistory() async {
    final db = DatabaseHelper.instance;
    final history = await db.getBattleHistory();
    _battleHistory = history.map((e) {
      return {
        'username': e['username'],
        'result': e['result'],
        'userTeam': json.decode(e['user_team']),
        'opponentTeam': json.decode(e['opponent_team']),
        'date': e['date'],
      };
    }).toList();
    notifyListeners();
  }


  // Inscription utilisateur
  Future<bool> registerUser(String username, String password) async {
    final db = DatabaseHelper.instance;
    try {
      await db.insertAccount(username, password);
      return true;
    } catch (e) {
      print("Erreur lors de l'inscription: $e");
      return false;
    }
  }

  // Connexion utilisateur
  Future<bool> loginUser(String username, String password) async {
    final db = DatabaseHelper.instance;
    final user = await db.getUser(username);
    if (user != null) {
      _currentUserId = user['id'];
      await loadBattleHistory();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Déconnexion utilisateur
  void logoutUser() {
    _currentUserId = null;
    _battleHistory.clear();
    notifyListeners();
  }
}
