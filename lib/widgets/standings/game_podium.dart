// lib/widgets/standings/game_podium.dart
import 'package:flutter/material.dart';

class GamePodium extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const GamePodium({
    Key? key,
    required this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: results.map((result) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: result['teamColor'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: _getMedalColor(result['position']),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${result['position']}°',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getMedalColor(result['position']),
                    ),
                  ),
                ],
              ),
              Text(
                result['teamName'],
                style: TextStyle(
                  color: result['teamColor'],
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (result['points'] != null)
                Text(
                  '${result['points']} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getMedalColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }
}