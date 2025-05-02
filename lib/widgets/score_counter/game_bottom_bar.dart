// lib/widgets/score_counter/game_bottom_bar.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';

class GameBottomBar extends StatelessWidget {
  final GameType activeGameType;
  final bool roundCalculated;
  final bool allTeamsAssigned;
  final bool hasSelectedTeams;
  final VoidCallback onAssignPosition;
  final VoidCallback onCalculateResult;
  final VoidCallback onNextGame;
  final bool isLastGame;
  final VoidCallback? onAddExtraGame;

  const GameBottomBar({
    Key? key,
    required this.activeGameType,
    required this.roundCalculated,
    required this.allTeamsAssigned,
    required this.hasSelectedTeams,
    required this.onAssignPosition,
    required this.onCalculateResult,
    required this.onNextGame,
    this.isLastGame = false,
    this.onAddExtraGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -3),
              blurRadius: 6,
            ),
          ],
        ),
        child: isLandscape
            ? _buildLandscapeLayout()
            : _buildPortraitLayout(),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    // Si el juego está completado, mostrar botones de siguiente juego y/o juego extra
    if (allTeamsAssigned) {
      // En el último juego, mostrar ambos botones si está disponible la opción de juego extra
      if (isLastGame && onAddExtraGame != null) {
        return Row(
          children: [
            // Botón de añadir juego extra
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildAnimatedButton(
                  text: 'Añadir Juego Extra',
                  icon: Icons.add_circle,
                  backgroundColor: Colors.amber,
                  isEnabled: true,
                  onPressed: onAddExtraGame,
                ),
              ),
            ),
            // Botón de ver tabla final
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _buildAnimatedButton(
                  text: 'Ver Tabla Final',
                  icon: Icons.leaderboard,
                  backgroundColor: Colors.purple,
                  isEnabled: true,
                  onPressed: onNextGame,
                ),
              ),
            ),
          ],
        );
      } else {
        // Si no es el último juego o no hay opción de juego extra, solo mostrar el botón de siguiente
        return _buildAnimatedButton(
          text: isLastGame ? 'Ver Tabla Final' : 'Siguiente Juego',
          icon: isLastGame ? Icons.leaderboard : Icons.arrow_forward,
          backgroundColor: isLastGame ? Colors.purple : Colors.blue,
          isEnabled: true,
          onPressed: onNextGame,
        );
      }
    } else {
      // Si el juego no está completado, mostrar el botón de asignar posición o calcular resultado
      if (activeGameType == GameType.normal) {
        return _buildAnimatedButton(
          text: 'Asignar Posición',
          icon: Icons.emoji_events,
          backgroundColor: Colors.green,
          isEnabled: hasSelectedTeams && !allTeamsAssigned,
          onPressed: hasSelectedTeams && !allTeamsAssigned ? onAssignPosition : null,
        );
      } else if (!roundCalculated) { // Juego por rondas y no calculado
        return _buildAnimatedButton(
          text: 'Calcular Resultado',
          icon: Icons.calculate,
          backgroundColor: Colors.green,
          isEnabled: true,
          onPressed: onCalculateResult,
        );
      } else {
        // Caso poco probable pero por completitud
        return const SizedBox.shrink();
      }
    }
  }
  
  Widget _buildLandscapeLayout() {
    // La lógica es similar al diseño vertical, pero adaptada para horizontal
    if (allTeamsAssigned) {
      // En el último juego, mostrar ambos botones si está disponible la opción de juego extra
      if (isLastGame && onAddExtraGame != null) {
        return Row(
          children: [
            // Botón de añadir juego extra
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildAnimatedButton(
                  text: 'Añadir Juego Extra',
                  icon: Icons.add_circle,
                  backgroundColor: Colors.amber,
                  isEnabled: true,
                  onPressed: onAddExtraGame,
                ),
              ),
            ),
            // Botón de ver tabla final
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _buildAnimatedButton(
                  text: 'Ver Tabla Final',
                  icon: Icons.leaderboard,
                  backgroundColor: Colors.purple,
                  isEnabled: true,
                  onPressed: onNextGame,
                ),
              ),
            ),
          ],
        );
      } else {
        // Si no es el último juego o no hay opción de juego extra, solo mostrar el botón de siguiente
        return _buildAnimatedButton(
          text: isLastGame ? 'Ver Tabla Final' : 'Siguiente Juego',
          icon: isLastGame ? Icons.leaderboard : Icons.arrow_forward,
          backgroundColor: isLastGame ? Colors.purple : Colors.blue,
          isEnabled: true,
          onPressed: onNextGame,
        );
      }
    } else {
      // Si el juego no está completado, mostrar el botón de asignar posición o calcular resultado
      if (activeGameType == GameType.normal) {
        return _buildAnimatedButton(
          text: 'Asignar Posición',
          icon: Icons.emoji_events,
          backgroundColor: Colors.green,
          isEnabled: hasSelectedTeams && !allTeamsAssigned,
          onPressed: hasSelectedTeams && !allTeamsAssigned ? onAssignPosition : null,
        );
      } else if (!roundCalculated) { // Juego por rondas y no calculado
        return _buildAnimatedButton(
          text: 'Calcular Resultado',
          icon: Icons.calculate,
          backgroundColor: Colors.green,
          isEnabled: true,
          onPressed: onCalculateResult,
        );
      } else {
        // Caso poco probable pero por completitud
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? backgroundColor : Colors.grey[300],
          foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 0 : 0,
        ),
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}