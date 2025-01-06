// lib/widgets/standings/team_row.dart
import 'package:flutter/material.dart';
import '../../models/team.dart';

class TeamRow extends StatelessWidget {
  final Team team;
  final int position;

  const TeamRow({
    Key? key,
    required this.team,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          if (position <= 3)
            Icon(
              Icons.emoji_events,
              color: position == 1
                  ? Colors.amber
                  : position == 2
                      ? Colors.grey[400]
                      : Colors.brown[300],
              size: 20,
            ),
          const SizedBox(width: 8),
          Text('$position°'),
          const SizedBox(width: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: team.teamColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(team.name),
          const Spacer(),
          Text(
            '${team.totalScore}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}