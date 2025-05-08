// lib/models/team.dart
import 'package:flutter/material.dart';

class Team {
  final int id;
  final String name;
  final Color teamColor;
  final int totalScore;
  final List<int?> gameScores;
  final List<int?> roundPoints; // Cambiado a una lista para mantener puntos por rondas por juego

  Team({
    required this.id,
    required this.name,
    required this.teamColor,
    this.totalScore = 0,
    List<int?>? gameScores,
    List<int?>? roundPoints, // Parámetro para roundPoints
  }) : 
    gameScores = gameScores ?? [],
    roundPoints = roundPoints ?? []; // Inicializar roundPoints como lista vacía si no se proporciona

  // Método para obtener los puntos de ronda de un juego específico
  int getRoundPoints(int gameIndex) {
    if (roundPoints.length > gameIndex && roundPoints[gameIndex] != null) {
      return roundPoints[gameIndex]!;
    }
    return 0;
  }

  Team copyWith({
    int? totalScore,
    List<int?>? gameScores,
    List<int?>? roundPoints,
  }) {
    return Team(
      id: id,
      name: name,
      teamColor: teamColor,
      totalScore: totalScore ?? this.totalScore,
      gameScores: gameScores ?? this.gameScores,
      roundPoints: roundPoints ?? this.roundPoints,
    );
  }

  Team updateGameScore(int gameIndex, int newScore) {
    final updatedScores = List<int?>.from(gameScores);
    if (updatedScores.length <= gameIndex) {
      while (updatedScores.length <= gameIndex) {
        updatedScores.add(null);
      }
    }
    updatedScores[gameIndex] = newScore;
    
    // Recalcular la puntuación total
    final newTotalScore = updatedScores.fold(0, (sum, s) => sum + (s ?? 0));
    
    return Team(
      id: id,
      name: name,
      teamColor: teamColor,
      totalScore: newTotalScore,
      gameScores: updatedScores,
      roundPoints: roundPoints,
    );
  }
  @override
  String toString() {
    return 'Team{id: $id, name: $name, totalScore: $totalScore, roundPoints: $roundPoints, gameScores: $gameScores}';
  }
}