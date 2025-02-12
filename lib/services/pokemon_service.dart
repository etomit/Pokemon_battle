import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  static const String baseUrl = "https://tyradex.vercel.app/api/v1/pokemon";

  // Récupérer tous les Pokémon
  static Future<List<dynamic>> fetchAllPokemon() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Échec de récupération des Pokémon");
    }
  }

  // Récupérer un Pokémon par ID
  static Future<Map<String, dynamic>> fetchPokemonDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Impossible de récupérer le Pokémon");
    }
  }
}
