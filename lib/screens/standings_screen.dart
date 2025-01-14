// lib/screens/standings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/standings/game_navigator.dart';
import '../widgets/standings/standings_table.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  int currentGameIndex = 0;

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final games = gameProvider.games;
    final teams = teamsProvider.teams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Posiciones'),
      ),
      body: Column(
        children: [
          GameNavigator(
            games: games,
            currentGameIndex: currentGameIndex,
            onGameIndexChanged: (index) => setState(() => currentGameIndex = index),
          ),
          Expanded(
            child: StandingsTable(
              games: games,
              teams: teams,
            ),
          ),
        ],
      ),
    );
  }
}