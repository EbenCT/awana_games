// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/score_counter_screen.dart';
import '../screens/standings_screen.dart';
import '../screens/game_rounds_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomeScreen(),
    '/score': (context) => const ScoreCounterScreen(),
    '/standings': (context) => const StandingsScreen(),
    '/rounds': (context) => const GameRoundsScreen(),
  };
}