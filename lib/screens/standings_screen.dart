// lib/screens/standings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/standings/game_navigator.dart';
import '../widgets/standings/standings_table.dart';
import '../widgets/standings/export_button.dart';
import 'edit_score_screen.dart';
import 'score_history_screen.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> with SingleTickerProviderStateMixin {
  int currentGameIndex = 0;
  late AnimationController _animationController;
  final GlobalKey<StandingsTableState> _tableKey = GlobalKey<StandingsTableState>();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de Cambios',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScoreHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Puntuaciones',
            onPressed: () {
              // Mostrar diálogo para seleccionar el juego a editar
              _showEditGameSelectionDialog(context);
            },
          ),
        ],
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
                key: _tableKey,
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
        child: ExportButton(tableKey: _tableKey),
      ),
    );
  }
  
  void _showEditGameSelectionDialog(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final games = gameProvider.games;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Juego'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                leading: Icon(
                  game.isCompleted ? Icons.check_circle : Icons.sports_esports,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(game.name),
                subtitle: Text(
                  game.isCompleted ? 'Completado' : 'En progreso',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScoreScreen(gameIndex: index),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}