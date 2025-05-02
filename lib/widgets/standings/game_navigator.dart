// lib/widgets/standings/game_navigator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game.dart';
import '../../providers/teams_provider.dart';
import 'game_podium.dart';
import 'navigation_header.dart';

class GameNavigator extends StatelessWidget {
  final List<Game> games;
  final int currentGameIndex;
  final Function(int) onGameIndexChanged;

  const GameNavigator({
    Key? key,
    required this.games,
    required this.currentGameIndex,
    required this.onGameIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink(); // No mostrar nada si no hay juegos
    }
    
    final currentGame = games[currentGameIndex];
    final gameResults = _calculateGameResults(context, currentGame);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              NavigationHeader(
                currentGame: currentGame,
                currentGameIndex: currentGameIndex,
                gamesLength: games.length,
                // En la tabla de posiciones sí permitimos navegar por todos los juegos
                onPrevious: currentGameIndex > 0 
                    ? () => onGameIndexChanged(currentGameIndex - 1) 
                    : null,
                onNext: currentGameIndex < games.length - 1 
                    ? () => onGameIndexChanged(currentGameIndex + 1) 
                    : null,
              ),
              if (gameResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                GamePodium(results: gameResults),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateGameResults(BuildContext context, Game game) {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    final teams = teamsProvider.teams;
    
    final results = teams.map((team) {
      final gameScore = team.gameScores.length > currentGameIndex
          ? team.gameScores[currentGameIndex]
          : null;
      
      return {
        'teamId': team.id,
        'teamName': team.name,
        'teamColor': team.teamColor,
        'score': gameScore,
        'points': game.type == GameType.rounds ? team.roundPoints : null,
      };
    }).toList();
    
    results.sort((a, b) => ((b['score'] ?? 0) as int).compareTo((a['score'] ?? 0) as int));
    _assignPositions(results);
    
    return results;
  }

  void _assignPositions(List<Map<String, dynamic>> results) {
    int currentPosition = 1;
    int sameScoreCount = 1;
    
    for (int i = 0; i < results.length; i++) {
      if (i > 0 && results[i]['score'] == results[i - 1]['score']) {
        results[i]['position'] = results[i - 1]['position'];
        sameScoreCount++;
      } else {
        results[i]['position'] = currentPosition;
        currentPosition = i + sameScoreCount + 1;
        sameScoreCount = 1;
      }
    }
  }
}