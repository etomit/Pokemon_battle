import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/main.dart';
import 'package:pokemon/providers/auth_providers.dart';
import 'package:pokemon/providers/pokemon_provider.dart';
import 'package:pokemon/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> openHome(WidgetTester tester, AuthProvider auth) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth),
        ChangeNotifierProvider(create: (_) => PokemonProvider()),
      ],
      child: MyApp(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Un visiteur doit se connecter avant un combat', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await openHome(tester, AuthProvider());
    expect(find.text('📖 Consulter le Pokédex'), findsOneWidget);
    expect(find.text('🎯 Composer mon équipe'), findsOneWidget);
    await tester.tap(find.text('⚔️ Lancer un combat'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Une session restaurée peut se déconnecter', (tester) async {
    SharedPreferences.setMockInitialValues({'username': 'Sacha'});
    final auth = AuthProvider();
    await auth.init();
    await openHome(tester, auth);
    expect(find.text('Déconnexion'), findsOneWidget);
    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();
    expect(auth.username, isNull);
    expect(find.text('Connexion'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('username'), isNull);
  });
}
