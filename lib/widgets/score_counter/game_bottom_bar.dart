// lib/widgets/score_counter/game_bottom_bar.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../common/primary_button.dart';

class GameBottomBar extends StatelessWidget {
  final GameType activeGameType;
  final bool roundCalculated;
  final bool allTeamsAssigned;
  final bool hasSelectedTeams;
  final VoidCallback onAssignPosition;
  final VoidCallback onCalculateResult;
  final VoidCallback onNextGame;

  const GameBottomBar({
    Key? key,
    required this.activeGameType,
    required this.roundCalculated,
    required this.allTeamsAssigned,
    required this.hasSelectedTeams,
    required this.onAssignPosition,
    required this.onCalculateResult,
    required this.onNextGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activeGameType == GameType.normal)
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Asignar Posición',
                  onPressed: hasSelectedTeams && !allTeamsAssigned
                      ? onAssignPosition
                      : () {},
                  backgroundColor: Colors.green,
                ),
              ),
            if (activeGameType == GameType.rounds && !roundCalculated)
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Calcular Resultado',
                  onPressed: onCalculateResult,
                  backgroundColor: Colors.green,
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Próximo Juego',
                onPressed: allTeamsAssigned ? onNextGame : () {},
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}