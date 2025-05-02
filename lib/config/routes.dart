// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/score_counter_screen.dart';
import '../screens/standings_screen.dart';
import '../screens/game_rounds_screen.dart';
import '../screens/game_config_screen.dart'; // Importar la nueva pantalla

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      case '/game_config': // Nueva ruta para la configuración de juegos
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GameConfigScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      case '/score':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ScoreCounterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      case '/standings':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const StandingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      case '/rounds':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GameRoundsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      default:
        // Si la ruta no está definida, muestra una página de error
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomeScreen(),
    '/game_config': (context) => const GameConfigScreen(), // Añadir la nueva ruta
    '/score': (context) => const ScoreCounterScreen(),
    '/standings': (context) => const StandingsScreen(),
    '/rounds': (context) => const GameRoundsScreen(),
  };
}