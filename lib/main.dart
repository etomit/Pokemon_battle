import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';
import 'screens/team_builder_screen.dart';
import 'screens/random_team_screen.dart';
import 'screens/combat_screen.dart';
import 'screens/combat_history_screen.dart';

void main() {
  final pokemonProvider = PokemonProvider();
  pokemonProvider.fetchPokemonList();

  runApp(
    ChangeNotifierProvider(
      create: (context) => pokemonProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth > 580 ? 6 : 3;
    double maxWidth = screenWidth > 580 ? 750 : 400;

    final provider = Provider.of<PokemonProvider>(context);
    List<Map<String, dynamic>> userTeam = provider.userTeam;

    return Scaffold(
      backgroundColor: Colors.red[600],
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: 700,
                  child: Image.asset(
                    'assets/pokemon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight *0.03),

            // boutons de navigation
            HomeButton(
              text: "📖 Consulter le Pokédex",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PokemonListScreen()),
                );
              },
            ),
            HomeButton(
              text: "🎯 Composer mon équipe",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamBuilderScreen()),
                );
              },
            ),
            HomeButton(
              text: "🎲 Générer une équipe aléatoire",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RandomTeamScreen()),
                );
              },
            ),
            HomeButton(
              text: "📁 Historique des combats",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombatHistoryScreen()),
                );
              },
            ),
            HomeButton(
              text: "⚔️ Lancer un combat",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BattleScreen()),
                );
              },
            ),
            if(userTeam.length == 6)... [
              Text(
                "Mon équipe",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1.0,
                ),
                itemCount: userTeam.length,
                itemBuilder: (context, index) {
                  final pokemon = userTeam[index];

                  return Card(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(pokemon["sprites"]["regular"], width: 35),
                        Text(pokemon["name"]["fr"], style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Widget bouton
class HomeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const HomeButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          backgroundColor: Colors.white,
          foregroundColor: Colors.red[900],
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
