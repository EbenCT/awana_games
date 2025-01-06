// lib/widgets/standings/game_progress_bar.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';

class GameProgressBar extends StatelessWidget {
  final List<Game> games;
  final int currentGameIndex;

  const GameProgressBar({
    Key? key,
    required this.games,
    required this.currentGameIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final isCurrentGame = index == currentGameIndex;

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: isCurrentGame ? Colors.purple[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: isCurrentGame
                  ? Border.all(color: Colors.purple, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  game.isCompleted
                      ? 'Completado'
                      : isCurrentGame
                          ? 'En Curso'
                          : 'Pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
