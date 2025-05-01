// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:awana_games/providers/teams_provider.dart';
import 'package:awana_games/providers/game_provider.dart';
import 'package:awana_games/screens/home_screen.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Crear providers para las pruebas
    final teamsProvider = TeamsProvider();
    final gameProvider = GameProvider();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TeamsProvider>.value(value: teamsProvider),
            ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
          ],
          child: const HomeScreen(),
        ),
      ),
    );

    // Verificar que la pantalla de inicio se carga correctamente
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verificar que hay un botón para iniciar el juego
    expect(find.text('Nuevo Juego'), findsOneWidget);
  });
  
  // Puedes agregar más pruebas específicas para tu aplicación
  // Por ejemplo:
  
  /*
  testWidgets('Navigation to ScoreCounter works', (WidgetTester tester) async {
    // Inicializar providers
    final teamsProvider = TeamsProvider();
    final gameProvider = GameProvider();
    
    // Build app
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TeamsProvider>.value(value: teamsProvider),
            ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
          ],
          child: const HomeScreen(),
        ),
      ),
    );
    
    // Tap on "Nuevo Juego" button
    await tester.tap(find.text('Nuevo Juego'));
    await tester.pumpAndSettle();
    
    // Verify we've navigated to ScoreCounterScreen
    expect(find.text('Juego 1'), findsOneWidget); // El nombre del primer juego
  });
  */
}