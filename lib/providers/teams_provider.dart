// lib/providers/teams_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamsProvider extends ChangeNotifier {
  
  final List<Team> _teams = [
    Team(id: 1, name: 'Rojo', teamColor: const Color(0xFFFF0000)),
    Team(id: 2, name: 'Amarillo', teamColor: const Color(0xFFFFC107)),
    Team(id: 3, name: 'Verde', teamColor: const Color(0xFF4CAF50)),
    Team(id: 4, name: 'Azul', teamColor: const Color(0xFF2196F3)),
  ];
  
  List<Team> get teams => _teams;

  List<Team> get sortedTeams {
    final sorted = List<Team>.from(_teams);
    sorted.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted;
  }

  void resetScores() {
    for (var team in _teams) {
      team.totalScore = 0;
      team.gameScores = [];
    }
    notifyListeners();
  }

void updateScore(int teamId, int gameIndex, int score) {
    final team = _teams.firstWhere((t) => t.id == teamId);
    while (team.gameScores.length <= gameIndex) {
        team.gameScores.add(null); // Asegura que la lista tenga el tamaño adecuado
    }
    team.gameScores[gameIndex] = score;
    team.totalScore = team.gameScores.fold(0, (sum, s) => sum + (s ?? 0));
    notifyListeners();
}

  void updateTeamScore(int teamId, int gameIndex, int score) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex != -1) {
      _teams[teamIndex].gameScores[gameIndex] = score;
      _teams[teamIndex].totalScore = _teams[teamIndex].gameScores
          .where((score) => score != null)
          .fold(0, (sum, score) => sum + score!);
      notifyListeners();
    }
  }

  void updateTeamRoundPoints(int teamId, int points) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex != -1) {
      _teams[teamIndex].roundPoints = points;
      notifyListeners();
    }
  }
}