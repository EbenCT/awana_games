// lib/widgets/score_counter/game_body.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../models/team.dart';
import '../common/score_card.dart';
import 'number_grid.dart';

class GameBody extends StatelessWidget {
  final List<Team> teams;
  final GameType activeGameType;
  final List<int> assignedTeams;
  final List<int> selectedTeams;
  final Map<int, int> currentGameScores;
  final bool roundCalculated;
  final Function(int, int) onTeamRoundPointsChanged;
  final Function(int, bool) onTeamSelected;
  final List<int> selectedNumbers;
  final Function(int) onNumberSelected;
  final int maxGridNumbers;
  final VoidCallback onAddNumber;

  const GameBody({
    Key? key,
    required this.teams,
    required this.activeGameType,
    required this.assignedTeams,
    required this.selectedTeams,
    required this.currentGameScores,
    required this.roundCalculated,
    required this.onTeamRoundPointsChanged,
    required this.onTeamSelected,
    required this.selectedNumbers,
    required this.onNumberSelected,
    required this.maxGridNumbers,
    required this.onAddNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...teams.map((team) {
          final isDisabled = assignedTeams.contains(team.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ScoreCard(
              team: team,
              showRoundPoints: activeGameType == GameType.rounds && !roundCalculated,
              onPointsChanged: activeGameType == GameType.rounds && !roundCalculated
                  ? (change) => onTeamRoundPointsChanged(team.id, change)
                  : null,
              isSelected: activeGameType == GameType.normal
                  ? selectedTeams.contains(team.id)
                  : false,
              onSelected: (activeGameType == GameType.normal && !isDisabled)
                  ? (isSelected) => onTeamSelected(team.id, isSelected)
                  : null,
              currentGameScore: currentGameScores[team.id] ?? 0,
            ),
          );
        }),
        if (activeGameType == GameType.rounds && !roundCalculated) ...[
          const SizedBox(height: 16),
          NumberGrid(
            selectedNumbers: selectedNumbers,
            onNumberSelected: onNumberSelected,
            maxNumbers: maxGridNumbers,
            onAddNumber: onAddNumber,
          ),
        ],
      ],
    );
  }
}