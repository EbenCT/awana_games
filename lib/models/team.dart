// lib/models/team.dart
import 'package:flutter/material.dart';

class Team {
  final int id;
  final String name;
  final Color teamColor;
  final int totalScore;
   int roundPoints;
  final List<int?> gameScores;

  Team({
    required this.id,
    required this.name,
    required this.teamColor,
    this.totalScore = 0,
    this.roundPoints = 0,
    List<int?>? gameScores,
  }) : gameScores = gameScores ?? [];

  Team copyWith({
    int? totalScore,
    int? roundPoints,
    List<int?>? gameScores,
  }) {
    return Team(
      id: id,
      name: name,
      teamColor: teamColor,
      totalScore: totalScore ?? this.totalScore,
      roundPoints: roundPoints ?? this.roundPoints,
      gameScores: gameScores ?? this.gameScores,
    );
  }

  @override
  String toString() {
    return 'Team{id: $id, name: $name, totalScore: $totalScore, roundPoints: $roundPoints, gameScores: $gameScores}';
  }
}