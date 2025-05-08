// lib/providers/teams_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/storage_service.dart';

class TeamsProvider extends ChangeNotifier {
  final List<Team> _teams = [
    Team(id: 1, name: 'Rojo', teamColor: const Color(0xFFFF0000)),
    Team(id: 2, name: 'Amarillo', teamColor: const Color(0xFFFFC107)),
    Team(id: 3, name: 'Verde', teamColor: const Color(0xFF4CAF50)),
    Team(id: 4, name: 'Azul', teamColor: const Color(0xFF2196F3)),
  ];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  List<Team> get sortedTeams {
    final sorted = List<Team>.from(_teams);
    sorted.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted;
  }

  // Inicializar el proveedor y cargar datos guardados
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    try {
      final savedTeams = await StorageService.loadTeams();
      if (savedTeams != null && savedTeams.isNotEmpty) {
        _teams.clear();
        _teams.addAll(savedTeams);
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TeamsProvider: $e');
    } finally {
      _isLoading = false;
    }
  }

  void resetScores() {
    for (int i = 0; i < _teams.length; i++) {
      final team = _teams[i];
      _teams[i] = Team(
        id: team.id,
        name: team.name,
        teamColor: team.teamColor,
        totalScore: 0,
        gameScores: [],
        roundPoints: [], // Inicializar lista de puntos por rondas
      );
    }
    _saveTeams();
    notifyListeners();
  }

  // Actualizar la puntuación de un juego
  void updateScore(int teamId, int gameIndex, int score) {
    final teamIndex = _teams.indexWhere((t) => t.id == teamId);
    if (teamIndex == -1) return;
    
    final team = _teams[teamIndex];
    
    // Asegurar que la lista de puntuaciones tenga el tamaño adecuado
    var gameScores = List<int?>.from(team.gameScores);
    while (gameScores.length <= gameIndex) {
      gameScores.add(null);
    }
    
    // Actualizar la puntuación del juego específico
    gameScores[gameIndex] = score;
    
    // Calcular la puntuación total
    final totalScore = gameScores.fold(0, (sum, s) => sum + (s ?? 0));
    
    // Mantener los puntos por rondas
    var roundPoints = List<int?>.from(team.roundPoints);
    
    // Actualizar el equipo con los nuevos valores
    _teams[teamIndex] = Team(
      id: team.id,
      name: team.name,
      teamColor: team.teamColor,
      totalScore: totalScore,
      gameScores: gameScores,
      roundPoints: roundPoints,
    );
    
    _saveTeams();
    notifyListeners();
  }

  // Actualizar los puntos de ronda para un juego específico
  void updateTeamRoundPoints(int teamId, int gameIndex, int points) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex == -1) return;
    
    final team = _teams[teamIndex];
    
    // Asegurar que la lista de puntos por rondas tenga el tamaño adecuado
    var roundPoints = List<int?>.from(team.roundPoints);
    while (roundPoints.length <= gameIndex) {
      roundPoints.add(null);
    }
    
    // Actualizar los puntos de ronda para el juego específico
    roundPoints[gameIndex] = points;
    
    // Actualizar el equipo
    _teams[teamIndex] = Team(
      id: team.id,
      name: team.name,
      teamColor: team.teamColor,
      totalScore: team.totalScore,
      gameScores: team.gameScores,
      roundPoints: roundPoints,
    );
    
    _saveTeams();
    notifyListeners();
  }

  // Obtener los puntos de ronda para un equipo y juego específicos
  int getTeamRoundPoints(int teamId, int gameIndex) {
    final team = _teams.firstWhere((t) => t.id == teamId, orElse: () => _teams[0]);
    
    if (team.roundPoints.length > gameIndex && team.roundPoints[gameIndex] != null) {
      return team.roundPoints[gameIndex]!;
    }
    
    return 0;
  }

  void updateTeamColor(int teamId, Color color) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex == -1) return;
    
    final team = _teams[teamIndex];
    
    // Como no podemos modificar el color directamente, creamos un nuevo equipo
    _teams[teamIndex] = Team(
      id: team.id,
      name: team.name,
      teamColor: color,
      totalScore: team.totalScore,
      gameScores: team.gameScores,
      roundPoints: team.roundPoints,
    );
    
    _saveTeams();
    notifyListeners();
  }

  void updateTeamName(int teamId, String name) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex == -1) return;
    
    final team = _teams[teamIndex];
    
    // Como no podemos modificar el nombre directamente, creamos un nuevo equipo
    _teams[teamIndex] = Team(
      id: team.id,
      name: name,
      teamColor: team.teamColor,
      totalScore: team.totalScore,
      gameScores: team.gameScores,
      roundPoints: team.roundPoints,
    );
    
    _saveTeams();
    notifyListeners();
  }

  // Método privado para guardar equipos
  Future<void> _saveTeams() async {
    try {
      await StorageService.saveTeams(_teams);
    } catch (e) {
      debugPrint('Error saving teams: $e');
    }
  }
}