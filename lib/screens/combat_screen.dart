import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import 'dart:math';

class BattleScreen extends StatefulWidget {
  @override
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late List<Map<String, dynamic>> playerTeam;
  late List<Map<String, dynamic>> enemyTeam;
  int currentPlayerIndex = 0;
  int currentEnemyIndex = 0;
  bool battleOver = false;
  String battleLog = "Le combat commence !";
  final Random random = Random();

  // Variables pour gérer les animations de PV
  double playerHpPercentage = 1.0;
  double enemyHpPercentage = 1.0;



  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PokemonProvider>(context, listen: false);
    playerTeam = provider.userTeam.map((p) => {...p, 'hp': p['stats']['hp'] * 2}).toList();
    enemyTeam = provider.randomTeam.map((p) => {...p, 'hp': p['stats']['hp'] * 2}).toList();

    if (playerTeam.isEmpty || enemyTeam.isEmpty) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showErrorDialog();
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Erreur"),
        content: Text("Votre équipe ou l'équipe ennemie est incomplète. Veuillez retourner à l'accueil pour corriger cela."),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')), // Retour à l'accueil
            child: Text("Retour à l'accueil"),
          ),
        ],
      ),
    );
  }

  void nextTurn() {
    if (battleOver) return;

    setState(() {
      battleLog = "";

      // Attaque du joueur
      final attacker = playerTeam[currentPlayerIndex];
      final defender = enemyTeam[currentEnemyIndex];
      int damage = calculateDamage(attacker, defender);

      // Attaque de l'ennemi
      final enemyAttacker = enemyTeam[currentEnemyIndex];
      final enemyDefender = playerTeam[currentPlayerIndex];
      int enemyDamage = calculateDamage(enemyAttacker, enemyDefender);

      // Vérification : si les deux attaques font exactement 0 dégâts, ils se blessent tous les deux
      if (damage == 0 && enemyDamage == 0) {
        battleLog = "${attacker['name']['fr']} et ${defender['name']['fr']} se ratent tous les deux et prennent 10 dégâts chacun !";
        attacker['hp'] -= 10;
        defender['hp'] -= 10;
        enemyAttacker['hp'] -= 10;
        enemyDefender['hp'] -= 10;
      } else {
        // Attaque du joueur
        if (damage <= 0) {
          battleLog = "${attacker['name']['fr']} rate son attaque et se blesse légèrement !";
          attacker['hp'] += damage;
        } else {
          defender['hp'] -= damage;
          battleLog = "${attacker['name']['fr']} attaque ${defender['name']['fr']} et inflige $damage dégâts !";
        }

        if (defender['hp'] < 1) {
          battleLog += " ${defender['name']['fr']} est K.O !";
          if (currentEnemyIndex < enemyTeam.length - 1) {
            currentEnemyIndex++;
            battleLog += " ${enemyTeam[currentEnemyIndex]['name']['fr']} entre en combat !";
          } else {
            battleLog = "Victoire ! Tous les Pokémon adverses sont K.O !";
            battleOver = true;
            _saveBattleResult();
            return;
          }
        }

        // Animation de la barre de vie du joueur
        playerHpPercentage = defender['hp'] / (defender['stats']['hp'] * 2);

        // Attaque de l'ennemi
        if (enemyDamage <= 0) {
          battleLog += "\n${enemyAttacker['name']['fr']} rate son attaque et se blesse légèrement !";
          enemyAttacker['hp'] += enemyDamage;
        } else {
          enemyDefender['hp'] -= enemyDamage;
          battleLog += "\n${enemyAttacker['name']['fr']} riposte et inflige $enemyDamage dégâts à ${enemyDefender['name']['fr']} !";
        }

        if (enemyDefender['hp'] < 1) {
          battleLog += " ${enemyDefender['name']['fr']} est K.O !";
          if (currentPlayerIndex < playerTeam.length - 1) {
            currentPlayerIndex++;
            battleLog += " ${playerTeam[currentPlayerIndex]['name']['fr']} entre en combat !";
          } else {
            battleLog = "Défaite... Tous vos Pokémon sont K.O !";
            battleOver = true;
            _saveBattleResult();
          }
        }

        // Animation de la barre de vie de l'ennemi
        enemyHpPercentage = enemyDefender['hp'] / (enemyDefender['stats']['hp'] * 2);
      }
    });
  }

  int calculateDamage(Map<String, dynamic> attacker, Map<String, dynamic> defender) {
    double baseDamage = attacker['stats']['atk'].toDouble();
    double multiplier = 1.0;

    for (var type in attacker['types']) {
      for (var resistance in defender['resistances']) {
        if (type['name'] == resistance['name']) {
          multiplier *= resistance['multiplier'];
        }
      }
    }

    double damageModifier = 0.35 + random.nextDouble() * 0.85;
    int calculatedDamage = (baseDamage * multiplier * damageModifier).round();

    bool isCritical = random.nextDouble() < 0.1;
    if (isCritical) {
      calculatedDamage = (calculatedDamage * 1.5).round();
    }

    if (damageModifier > 1.0 && random.nextDouble() < 0.3) {
      return - (calculatedDamage ~/ 10);
    }

    return calculatedDamage;
  }

  Widget buildHealthBar(Map<String, dynamic> pokemon) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: pokemon['hp'] / (pokemon['stats']['hp'] * 2), end: pokemon['hp'] / (pokemon['stats']['hp'] * 2)),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        Color barColor;
        if (value > 0.6) {
          barColor = Colors.green;
        } else if (value > 0.3) {
          barColor = Colors.yellow;
        } else {
          barColor = Colors.red;
        }

        return Column(
          children: [
            Container(
              width: 150.0,
              child: LinearProgressIndicator(
                value: value,
                color: barColor,
                backgroundColor: Colors.grey,
                minHeight: 10,
              ),
            ),
            Text("${(value * pokemon['stats']['hp'] * 2).toInt()} PV", style: TextStyle(color: Colors.white)),
          ],
        );
      },
    );
  }

  void _saveBattleResult() {
    final provider = Provider.of<PokemonProvider>(context, listen: false);
    provider.saveBattleHistory(
      battleLog.contains("Victoire") ? "Victoire" : "Défaite",
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(title: Text("Combat Pokémon",style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.grey[900]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!battleOver) ...[
              buildHealthBar(enemyTeam[currentEnemyIndex]),
              Image.network(enemyTeam[currentEnemyIndex]['sprites']['regular'], width: 150.0),
              SizedBox(height: 20),
              buildHealthBar(playerTeam[currentPlayerIndex]),
              Image.network(playerTeam[currentPlayerIndex]['sprites']['regular'], width: 150.0),
            ],
            SizedBox(height: 30),
            SizedBox(
              height: 60,
              child : Text(battleLog, textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: battleOver ? () => Navigator.pop(context) : nextTurn,
              child: Text(battleOver ? "Retour au menu" : "Suivant", style: TextStyle(fontSize: 24,color: Colors.grey[900])),
            ),
          ],
        ),
      ),
    );
  }
}