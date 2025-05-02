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
  final VoidCallback? onAddExtraGame; // Nueva propiedad para añadir juego extra

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
    this.onAddExtraGame, // Opcional, solo se usa en el último juego
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botones principales según el tipo de juego
        if (activeGameType == GameType.normal)
          _buildAnimatedButton(
            text: 'Asignar Posición',
            icon: Icons.emoji_events,
            backgroundColor: Colors.green,
            isEnabled: hasSelectedTeams && !allTeamsAssigned,
            onPressed: hasSelectedTeams && !allTeamsAssigned
                ? onAssignPosition
                : null,
          ),
        if (activeGameType == GameType.rounds && !roundCalculated)
          _buildAnimatedButton(
            text: 'Calcular Resultado',
            icon: Icons.calculate,
            backgroundColor: Colors.green,
            isEnabled: true,
            onPressed: onCalculateResult,
          ),
          
        // Botón de añadir juego extra (solo en el último juego)
        if (isLastGame && onAddExtraGame != null && allTeamsAssigned) ...[
          const SizedBox(height: 8),
          _buildAnimatedButton(
            text: 'Añadir Juego Extra',
            icon: Icons.add_circle,
            backgroundColor: Colors.amber,
            isEnabled: true,
            onPressed: onAddExtraGame,
          ),
        ],
          
        const SizedBox(height: 8),
        
        // Botón de siguiente juego o ver tabla final
        _buildAnimatedButton(
          text: isLastGame ? 'Ver Tabla Final' : 'Siguiente Juego',
          icon: isLastGame ? Icons.leaderboard : Icons.arrow_forward,
          backgroundColor: isLastGame ? Colors.purple : Colors.blue,
          isEnabled: allTeamsAssigned,
          onPressed: allTeamsAssigned ? onNextGame : null,
        ),
      ],
    );
  }
  
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Primera columna: botones de acción según tipo de juego
        if (activeGameType == GameType.normal)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildAnimatedButton(
                text: 'Asignar Posición',
                icon: Icons.emoji_events,
                backgroundColor: Colors.green,
                isEnabled: hasSelectedTeams && !allTeamsAssigned,
                onPressed: hasSelectedTeams && !allTeamsAssigned
                    ? onAssignPosition
                    : null,
              ),
            ),
          ),
        if (activeGameType == GameType.rounds && !roundCalculated)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildAnimatedButton(
                text: 'Calcular Resultado',
                icon: Icons.calculate,
                backgroundColor: Colors.green,
                isEnabled: true,
                onPressed: onCalculateResult,
              ),
            ),
          ),
          
        // Segunda columna: juego extra (si es el último juego)
        if (isLastGame && onAddExtraGame != null && allTeamsAssigned)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildAnimatedButton(
                text: 'Añadir Juego Extra',
                icon: Icons.add_circle,
                backgroundColor: Colors.amber,
                isEnabled: true,
                onPressed: onAddExtraGame,
              ),
            ),
          ),
        
        // Tercera columna: botón de siguiente juego o tabla final
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isLastGame ? 0 : 8),
            child: _buildAnimatedButton(
              text: isLastGame ? 'Ver Tabla Final' : 'Siguiente Juego',
              icon: isLastGame ? Icons.leaderboard : Icons.arrow_forward,
              backgroundColor: isLastGame ? Colors.purple : Colors.blue,
              isEnabled: allTeamsAssigned,
              onPressed: allTeamsAssigned ? onNextGame : null,
            ),
          ),
        ),
      ],
    );
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