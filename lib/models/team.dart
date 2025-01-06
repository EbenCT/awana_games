import 'package:flutter/material.dart';
// lib/models/team.dart
class Team {
  final int id;
  final String name;
  final Color teamColor;
  int totalScore;
  int roundPoints;
  List<int?> gameScores;

  Team({
    required this.id,
    required this.name,
    required this.teamColor,
    this.totalScore = 0,
    this.roundPoints = 0,
    List<int?>? gameScores,
  }) : this.gameScores = gameScores ?? List.filled(5, null);

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
}