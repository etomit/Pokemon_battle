import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../services/database_helper.dart';
import 'dart:convert';

class CombatHistoryScreen extends StatefulWidget {
  @override
  _CombatHistoryScreenState createState() => _CombatHistoryScreenState();
}

class _CombatHistoryScreenState extends State<CombatHistoryScreen> {
  List<Map<String, dynamic>> battleHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBattleHistory();
  }

  Future<void> _loadBattleHistory() async {
    final db = DatabaseHelper.instance;
    final history = await db.getBattleHistory();
    setState(() {
      battleHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique des combats", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[800],
      body: battleHistory.isEmpty
          ? Center(
        child: Text(
          "Aucun combat enregistré.",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView.builder(
            itemCount: battleHistory.length,
            itemBuilder: (context, index) {
              final combat = battleHistory[index];
              final isVictory = combat['result'] == "Victoire";
              return Card(
                color: isVictory ? Colors.green[500] : Colors.red[500],
                margin: EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Combat de ${combat['username']}: ${combat['result']}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Équipe du joueur:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      _buildPokemonTeam(combat['userTeam']),
                      SizedBox(height: 10),
                      Text(
                        "Équipe adverse:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      _buildPokemonTeam(combat['opponentTeam']),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonTeam(String teamJson) {
    List<dynamic> team = teamJson.isNotEmpty ? List<Map<String, dynamic>>.from(json.decode(teamJson)) : [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: team.map<Widget>((pokemon) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Image.network(
                  pokemon['sprites']['regular'],
                  width: 70,
                  height: 70,
                ),
                SizedBox(height: 5),
                Text(
                  pokemon['name']['fr'],
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
