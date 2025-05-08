// lib/main.dart (modificado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/teams_provider.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart'; // Añadido

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar los providers antes de construir la app
  final teamsProvider = TeamsProvider();
  final gameProvider = GameProvider();
  final themeProvider = ThemeProvider(); // Añadido
  
  // Cargar datos guardados de manera asíncrona
  await Future.wait([
    teamsProvider.initialize(),
    gameProvider.initialize(),
    themeProvider.initialize(), // Añadido
  ]);
  
  runApp(MyApp(
    teamsProvider: teamsProvider,
    gameProvider: gameProvider,
    themeProvider: themeProvider, // Añadido
  ));
}

class MyApp extends StatelessWidget {
  final TeamsProvider teamsProvider;
  final GameProvider gameProvider;
  final ThemeProvider themeProvider; // Añadido
  
  const MyApp({
    Key? key,
    required this.teamsProvider,
    required this.gameProvider,
    required this.themeProvider, // Añadido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: teamsProvider),
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: themeProvider), // Añadido
      ],
      child: Consumer<ThemeProvider>( // Añadido
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Awana Games',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme, // Añadido
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Añadido
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/',
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}