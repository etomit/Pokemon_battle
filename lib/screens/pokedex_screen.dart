import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import 'pokemon_detail_screen.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  int? hoveredPokemonId;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PokemonProvider>(context);
    final pokemonList = provider.pokemonList.where((pokemon) {
      final name = pokemon["name"]["fr"].toLowerCase();
      final id = pokemon["pokedex_id"];
      return name.contains(searchQuery.toLowerCase()) && id != 0;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.red[700],
      appBar: AppBar(
        title: Text("Pokédex", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un Pokémon...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: pokemonList.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: pokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = pokemonList[index];

                      return MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            hoveredPokemonId = pokemon["pokedex_id"];
                            provider.fetchPokemonDetails(pokemon["pokedex_id"]);
                          });
                        },
                        child: ListTile(
                          leading: Image.network(pokemon["sprites"]["regular"], width: 50),
                          title: Text(pokemon["name"]["fr"], style: TextStyle(color: Colors.grey[100])),
                          tileColor: hoveredPokemonId == pokemon["pokedex_id"]
                              ? Colors.red[300]
                              : Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: hoveredPokemonId == null
                      ? Center(
                    child: Text(
                      "Survolez un Pokémon pour voir ses détails",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                      : Container(
                    color: Colors.grey[100],
                    child: PokemonDetailScreen(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
