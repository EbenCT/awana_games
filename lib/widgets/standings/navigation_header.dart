// lib/widgets/standings/navigation_header.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../common/edit_game_dialog.dart';

class NavigationHeader extends StatelessWidget {
  final Game currentGame;
  final int currentGameIndex;
  final int gamesLength;
  final VoidCallback? onPrevious; // Cambiar a que acepte nulo
  final VoidCallback? onNext;     // Cambiar a que acepte nulo

  const NavigationHeader({
    Key? key,
    required this.currentGame,
    required this.currentGameIndex,
    required this.gamesLength,
    this.onPrevious, // Hacer opcional
    this.onNext,     // Hacer opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious, // Ya acepta nulo
          color: onPrevious != null ? null : Colors.grey[400], // Cambiar color si está deshabilitado
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
          onPressed: onNext, // Ya acepta nulo
          color: onNext != null ? null : Colors.grey[400], // Cambiar color si está deshabilitado
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