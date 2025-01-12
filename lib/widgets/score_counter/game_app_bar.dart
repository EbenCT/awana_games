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
          ? InkWell(
              onTap: onEditGame,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(currentGame!.name),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 16),
                ],
              ),
            )
          : const Text('Sin Juego'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.leaderboard),
          onPressed: () => Navigator.pushNamed(context, '/standings'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}