import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import 'dart:math';

class RandomTeamScreen extends StatefulWidget {
  @override
  _RandomTeamScreenState createState() => _RandomTeamScreenState();
}

class _RandomTeamScreenState extends State<RandomTeamScreen> {
  void generateRandomTeam(PokemonProvider provider) {
    final random = Random();

    final filteredPokemonList = provider.pokemonList.where((pokemon) {
      return pokemon["pokedex_id"] != 0;
    }).toList();
    provider.generateRandomTeam(filteredPokemonList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PokemonProvider>(context);

    return Scaffold(
      backgroundColor: Colors.red[700],
      appBar: AppBar(
        title: Text("Générer une équipe aléatoire", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => generateRandomTeam(provider),
              child: Text("🎲 Générer une équipe", style: TextStyle(fontSize: 24,color: Colors.red[900])),
            ),
            SizedBox(height: 30),
            provider.randomTeam.isEmpty
                ? Text(
              "Aucune équipe générée",
              style: TextStyle(color: Colors.white),
            )
                : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: provider.randomTeam.map((pokemon) {
                  return Container(
                    width: 250,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Image.network(
                                pokemon["sprites"]["regular"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            pokemon["name"]["fr"],
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
