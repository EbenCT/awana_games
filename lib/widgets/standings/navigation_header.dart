// lib/widgets/standings/navigation_header.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../common/edit_game_dialog.dart';

class NavigationHeader extends StatelessWidget {
  final Game currentGame;
  final int currentGameIndex;
  final int gamesLength;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const NavigationHeader({
    Key? key,
    required this.currentGame,
    required this.currentGameIndex,
    required this.gamesLength,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentGameIndex > 0 ? onPrevious : null,
        ),
        Expanded(
          child: Column(
            children: [
              const Text(
                'Resultados por juego',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              InkWell(
                onTap: () => _showEditGameNameDialog(context, currentGame),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        currentGame.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentGameIndex < gamesLength - 1 ? onNext : null,
        ),
      ],
    );
  }

  void _showEditGameNameDialog(BuildContext context, Game game) {
    showDialog(
      context: context,
      builder: (context) => EditGameDialog(game: game, gameIndex: currentGameIndex),
    );
  }
}