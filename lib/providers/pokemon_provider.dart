import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _pokemonDetails;

  List<Map<String, dynamic>> _randomTeam = [];
  List<Map<String, dynamic>> _userTeam = [];
  List<Map<String, dynamic>> _battleHistory = [];

  // Getters
  List<Map<String, dynamic>> get pokemonList => _pokemonList;
  Map<String, dynamic>? get pokemonDetails => _pokemonDetails;
  List<Map<String, dynamic>> get randomTeam => _randomTeam;
  List<Map<String, dynamic>> get userTeam => _userTeam;
  List<Map<String, dynamic>> get battleHistory => _battleHistory;

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
  void addBattleToHistory(String result, List<Map<String, dynamic>> userTeam, List<Map<String, dynamic>> opponentTeam) {
    _battleHistory.add({
      'result': result,
      'userTeam': List.from(userTeam),
      'opponentTeam': List.from(opponentTeam),
      'date': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  void clearBattleHistory() {
    _battleHistory.clear();
    notifyListeners();
  }
}
