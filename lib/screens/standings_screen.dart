// lib/screens/standings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/standings/game_navigator.dart';
import '../widgets/standings/standings_table.dart';
import '../widgets/standings/export_button.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> with SingleTickerProviderStateMixin {
  int currentGameIndex = 0;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final games = gameProvider.games;
    final teams = teamsProvider.teams;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Posiciones'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeIn,
        ),
        child: Column(
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.elasticOut,
              )),
              child: GameNavigator(
                games: games,
                currentGameIndex: currentGameIndex,
                onGameIndexChanged: (index) => setState(() => currentGameIndex = index),
              ),
            ),
            Expanded(
              child: StandingsTable(
                games: games,
                teams: teams,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: const ExportButton(),
      ),
    );
  }
}