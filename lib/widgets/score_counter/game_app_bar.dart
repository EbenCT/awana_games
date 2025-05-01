// lib/widgets/score_counter/game_app_bar.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Game? currentGame;
  final VoidCallback onEditGame;

  const GameAppBar({
    Key? key,
    required this.currentGame,
    required this.onEditGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: currentGame != null
          ? Hero(
              tag: 'game_title_${currentGame!.id}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEditGame,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currentGame!.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Text('Sin Juego'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Hero(
          tag: 'leaderboard_button',
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.leaderboard),
              tooltip: 'Ver tabla de posiciones',
              onPressed: () => Navigator.pushNamed(context, '/standings'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}