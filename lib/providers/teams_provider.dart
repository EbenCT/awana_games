// lib/providers/teams_provider.dart
import 'package:flutter/foundation.dart';
import '../models/team.dart';

class TeamsProvider extends ChangeNotifier {
  List<Team> _teams = [];
  
  List<Team> get teams => _teams;
  List<Team> get sortedTeams {
    final sorted = List<Team>.from(_teams);
    sorted.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted;
  }

  void initializeTeams(List<Team> teams) {
    _teams = teams;
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