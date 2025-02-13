import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pokemon_provider.dart';
import 'providers/auth_providers.dart';
import 'screens/pokedex_screen.dart';
import 'screens/team_builder_screen.dart';
import 'screens/random_team_screen.dart';
import 'screens/combat_screen.dart';
import 'screens/combat_history_screen.dart';
import 'services/database_helper.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("loading database");
  await DatabaseHelper.instance.init();
  print("database loaded");

  final authProvider = AuthProvider();
  await authProvider.init();

  final pokemonProvider = PokemonProvider();
  pokemonProvider.fetchPokemonList();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => pokemonProvider),
        ChangeNotifierProvider(create: (context) => authProvider),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pokémon App',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignupScreen(),
          },
        );
      },
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

    final pokemonProvider = Provider.of<PokemonProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    List<Map<String, dynamic>> userTeam = pokemonProvider.userTeam;

    return Scaffold(
      backgroundColor: Colors.red[600],
      appBar: AppBar(
        title: Text('Pokémon App', style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.red[900],
        actions: [
          authProvider.username == null
              ? TextButton.icon(
            icon: Icon(Icons.login, color: Colors.white), // Icône en blanc
            label: Text('Connexion', style: TextStyle(color: Colors.white, fontSize: 20)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          )
              : TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.white), // Icône en blanc
            label: Text('Déconnexion', style: TextStyle(color: Colors.white, fontSize: 20)),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
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
            SizedBox(height: screenHeight * 0.03),

            // Boutons de navigation
            HomeButton(
              text: "📖 Consulter le Pokédex",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PokemonListScreen()));
              },
            ),
            HomeButton(
              text: "🎯 Composer mon équipe",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TeamBuilderScreen()));
              },
            ),
            HomeButton(
              text: "🎲 Générer une équipe aléatoire",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RandomTeamScreen()));
              },
            ),
            HomeButton(
              text: "📁 Historique des combats",
              onPressed: () {
                if (authProvider.username == null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CombatHistoryScreen()));
                }
              },
            ),
            HomeButton(
              text: "⚔️ Lancer un combat",
              onPressed: () {
                if (authProvider.username == null) {
                  Navigator.pushNamed(context, "/login");
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BattleScreen()));
                }
              },
            ),
            if (userTeam.length == 6) ...[
              Text(
                "Mon équipe",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
