import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PokemonProvider>(context);
    final pokemon = provider.pokemonDetails;

    if (pokemon == null) {
      return Center(
        child: Text(
          "Impossible d'afficher ce Pokémon.",
          style: TextStyle(color: Colors.black54, fontSize: 18),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Image.network(pokemon["sprites"]["regular"], width: 150),
          Text(
            pokemon["name"]["fr"],
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10),
          pokemon["types"].isEmpty
              ? Container()
              : Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: pokemon["types"].map<Widget>((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.network(
                    type["image"],
                    width: 30,
                    height: 30,
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 10),
          Text("PV: ${pokemon["stats"]["hp"]}", style: TextStyle(fontSize: 18, color: Colors.green[800])),
          Text("Attaque: ${pokemon["stats"]["atk"]}", style: TextStyle(fontSize: 18, color: Colors.red[700])),
          Text("Attaque spé: ${pokemon["stats"]["spe_atk"]}", style: TextStyle(fontSize: 18, color: Colors.red[900])),
          Text("Défense: ${pokemon["stats"]["def"]}", style: TextStyle(fontSize: 18, color: Colors.blue[500])),
          Text("Défense spé: ${pokemon["stats"]["spe_def"]}", style: TextStyle(fontSize: 18, color: Colors.blue[800])),
          Text("Vitesse: ${pokemon["stats"]["vit"]}", style: TextStyle(fontSize: 18, color: Colors.grey[900])),
        ],
      ),
    );
  }
}
