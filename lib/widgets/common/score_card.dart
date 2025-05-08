// lib/widgets/common/score_card.dart
import 'package:flutter/material.dart';
import '../../models/team.dart';

class ScoreCard extends StatelessWidget {
  final Team team;
  final bool showRoundPoints;
  final int roundPoints; // Nuevo parámetro para los puntos por rondas
  final Function(int)? onPointsChanged;
  final bool isSelected;
  final Function(bool)? onSelected;
  final int currentGameScore;

  const ScoreCard({
    Key? key,
    required this.team,
    this.showRoundPoints = false,
    this.roundPoints = 0, // Valor por defecto
    this.onPointsChanged,
    this.isSelected = false,
    this.onSelected,
    this.currentGameScore = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.identity()
        ..scale(isSelected ? 1.02 : 1.0),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
            ? BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              )
            : BorderSide.none,
        ),
        color: team.teamColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: isSmallScreen ? 8.0 : 12.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team name section
              Flexible(
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: isSelected ? value * 0.1 : 0,
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        team.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Score section
              if (showRoundPoints)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onPointsChanged?.call(-1),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '$roundPoints', // Usar el parámetro de puntos por rondas
                          key: ValueKey<int>(roundPoints),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onPointsChanged?.call(1),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    if (onSelected != null)
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white.withOpacity(0.7),
                        ),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: onSelected != null
                            ? (value) => onSelected?.call(value ?? false)
                            : null,
                          checkColor: team.teamColor,
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        '$currentGameScore',
                        key: ValueKey<int>(currentGameScore),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}