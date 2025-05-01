// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/teams_provider.dart';
import 'providers/game_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar los providers antes de construir la app
  final teamsProvider = TeamsProvider();
  final gameProvider = GameProvider();
  
  // Cargar datos guardados de manera asíncrona
  await Future.wait([
    teamsProvider.initialize(),
    gameProvider.initialize(),
  ]);
  
  runApp(MyApp(
    teamsProvider: teamsProvider,
    gameProvider: gameProvider,
  ));
}

class MyApp extends StatelessWidget {
  final TeamsProvider teamsProvider;
  final GameProvider gameProvider;
  
  const MyApp({
    Key? key, 
    required this.teamsProvider,
    required this.gameProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: teamsProvider),
        ChangeNotifierProvider.value(value: gameProvider),
      ],
      child: MaterialApp(
        title: 'Awana Games',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}