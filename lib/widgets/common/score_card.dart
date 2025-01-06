import 'package:flutter/material.dart';
import '../../models/team.dart';

class ScoreCard extends StatelessWidget {
  final Team team;
  final bool showRoundPoints;
  final Function(int)? onPointsChanged;
  final bool isSelected; // Nuevo parámetro
  final Function(bool)? onSelected; // Nuevo parámetro

  const ScoreCard({
    Key? key,
    required this.team,
    this.showRoundPoints = false,
    this.onPointsChanged,
    this.isSelected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: team.teamColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (showRoundPoints)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () => onPointsChanged?.call(-1),
                    ),
                    Text(
                      '${team.roundPoints}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => onPointsChanged?.call(1),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: onSelected != null
                        ? (value) => onSelected?.call(value ?? false)
                        : null,
                  ),
                  Text(
                    '${team.totalScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
