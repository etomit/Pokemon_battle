import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';

class TeamBuilderScreen extends StatefulWidget {
  @override
  _TeamBuilderScreenState createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = _getColumnCount(screenWidth);
    final provider = Provider.of<PokemonProvider>(context);
    List<Map<String, dynamic>> selectedTeam = provider.userTeam;

    // Filtrer la liste des Pokémon en fonction de la recherche et exclure l'ID 0
    List<Map<String, dynamic>> filteredPokemonList = provider.pokemonList.where((pokemon) {
      final name = pokemon["name"]["fr"].toLowerCase();
      final id = pokemon["pokedex_id"];
      return name.contains(searchQuery.toLowerCase()) && id != 0;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.red[700],
      appBar: AppBar(
        title: Text("Composer mon équipe", style: TextStyle(color: Colors.white)),
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
          Text(
            "Pokémons sélectionnés : ${selectedTeam.length} / 6",
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: filteredPokemonList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredPokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = filteredPokemonList[index];
                bool isSelected = selectedTeam.any((teamPokemon) => teamPokemon["pokedex_id"] == pokemon["pokedex_id"]);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        provider.removePokemonFromUserTeam(pokemon);
                      } else if (selectedTeam.length < 6) {
                        provider.addPokemonToUserTeam(pokemon);
                      }
                    });
                  },
                  child: Card(
                    color: isSelected ? Colors.green[300] : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(pokemon["sprites"]["regular"], width: 50),
                        Text(pokemon["name"]["fr"]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: selectedTeam.isNotEmpty ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
              children: [
                if (selectedTeam.isNotEmpty)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          provider.clearUserTeam();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red[900],
                      ),
                      child: Text("Vider mon équipe", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedTeam.length == 6 ? () {
                      Navigator.pop(context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedTeam.length == 6 ? Colors.white : Colors.grey,
                      foregroundColor: Colors.red[900],
                    ),
                    child: Text("Confirmer mon équipe", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getColumnCount(double screenWidth) {
    if (screenWidth < 600) {
      return 4; // Écran petit
    } else if (screenWidth < 900) {
      return 6; // Écran moyen
    } else if (screenWidth < 1200) {
      return 8; // Écran large
    } else {
      return 10; // Très grand écran
    }
  }
}
