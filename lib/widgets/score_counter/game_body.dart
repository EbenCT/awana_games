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
  final Map<int, int> currentRoundPoints; // Nuevo mapa para puntos por rondas
  final bool roundCalculated;
  final Function(int, int) onTeamRoundPointsChanged;
  final Function(int, bool) onTeamSelected;
  final List<int> selectedNumbers;
  final Function(int) onNumberSelected;
  final int maxGridNumbers;
  final VoidCallback onAddNumber;
  final bool isLandscape;
  final int gameIndex; // Nuevo parámetro para el índice del juego actual

  const GameBody({
    Key? key,
    required this.teams,
    required this.activeGameType,
    required this.assignedTeams,
    required this.selectedTeams,
    required this.currentGameScores,
    required this.currentRoundPoints, // Requerido nuevo parámetro
    required this.roundCalculated,
    required this.onTeamRoundPointsChanged,
    required this.onTeamSelected,
    required this.selectedNumbers,
    required this.onNumberSelected,
    required this.maxGridNumbers,
    required this.onAddNumber,
    required this.gameIndex, // Requerido nuevo parámetro
    this.isLandscape = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      return _buildLandscapeLayout();
    }

    return _buildPortraitLayout();
  }

  Widget _buildPortraitLayout() {
    // Usamos Column con ListView interno para evitar problemas de layout
    return Column(
      children: [
        // Team cards - Usamos ListView con altura fija para evitar problemas de layout
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ...teams.asMap().entries.map((entry) {
                final index = entry.key;
                final team = entry.value;
                final isDisabled = assignedTeams.contains(team.id);
                
                // Obtener los puntos de ronda actuales para este equipo
                final roundPoints = currentRoundPoints[team.id] ?? 0;
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  curve: Curves.easeOutCubic, // Cambiado para evitar rebote excesivo
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0), // Asegurar valor válido de opacidad
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ScoreCard(
                            team: team,
                            showRoundPoints: activeGameType == GameType.rounds && !roundCalculated,
                            roundPoints: roundPoints, // Pasar los puntos por rondas actuales
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
                        ),
                      ),
                    );
                  },
                );
              }).toList(),

              if (activeGameType == GameType.rounds && !roundCalculated) ...[
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: NumberGrid(
                    selectedNumbers: selectedNumbers,
                    onNumberSelected: onNumberSelected,
                    maxNumbers: maxGridNumbers,
                    onAddNumber: onAddNumber,
                  ),
                ),
                // Agregar espacio adicional para evitar que el contenido se corte
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    if (activeGameType == GameType.rounds && !roundCalculated) {
      // For rounds game type, split the screen into teams and number grid
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Team cards column
          Expanded(
            flex: 1,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: teams.map((team) {
                // Obtener los puntos de ronda actuales para este equipo
                final roundPoints = currentRoundPoints[team.id] ?? 0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ScoreCard(
                    team: team,
                    showRoundPoints: true,
                    roundPoints: roundPoints, // Pasar los puntos por rondas actuales
                    onPointsChanged: (change) => onTeamRoundPointsChanged(team.id, change),
                    currentGameScore: currentGameScores[team.id] ?? 0,
                  ),
                );
              }).toList(),
            ),
          ),
          // Number grid column
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( // Envolvemos en un SingleChildScrollView para manejar contenido grande
                child: NumberGrid(
                  selectedNumbers: selectedNumbers,
                  onNumberSelected: onNumberSelected,
                  maxNumbers: maxGridNumbers,
                  onAddNumber: onAddNumber,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // For normal game type, just show the teams in a grid
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          final isDisabled = assignedTeams.contains(team.id);
          
          // En el modo normal no usamos puntos por rondas
          return ScoreCard(
            team: team,
            showRoundPoints: false,
            isSelected: activeGameType == GameType.normal
              ? selectedTeams.contains(team.id)
              : false,
            onSelected: (activeGameType == GameType.normal && !isDisabled)
              ? (isSelected) => onTeamSelected(team.id, isSelected)
              : null,
            currentGameScore: currentGameScores[team.id] ?? 0,
          );
        },
      );
    }
  }
}