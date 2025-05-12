// lib/services/storage_service.dart (actualizado)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/game.dart';
import 'package:flutter/material.dart';

class StorageService {
  static const String _teamsKey = 'teams';
  static const String _gamesKey = 'games';
  static const String _maxGridNumbersKey = 'maxGridNumbers';
  static const String _configStateKey = 'configState';
  static const String _scoreHistoryKey = 'scoreHistory';
  static const String _onboardingCompletedKey = 'onboarding_completed'; // Añadido
  static const String _scheduleDayKey = 'schedule_day'; // Añadido
  static const String _scheduleTimeKey = 'schedule_time_minutes'; // Añadido
  static const String _notificationsEnabledKey = 'notifications_enabled'; // Añadido

  // Guardar equipos
  static Future<void> saveTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final teamsData = teams.map((team) => {
      'id': team.id,
      'name': team.name,
      'teamColor': team.teamColor.value,
      'totalScore': team.totalScore,
      'gameScores': team.gameScores,
      'roundPoints': team.roundPoints,
    }).toList();
    await prefs.setString(_teamsKey, jsonEncode(teamsData));
  }

  // Cargar equipos
  static Future<List<Team>?> loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsString = prefs.getString(_teamsKey);
    if (teamsString == null) return null;
    try {
      final List<dynamic> teamsData = jsonDecode(teamsString);
      return teamsData.map((data) => Team(
        id: data['id'],
        name: data['name'],
        teamColor: Color(data['teamColor']),
        totalScore: data['totalScore'],
        gameScores: List<int?>.from(data['gameScores'] ?? []),
        roundPoints: List<int?>.from(data['roundPoints'] ?? []),
      )).toList();
    } catch (e) {
      print('Error loading teams: $e');
      return null;
    }
  }

  // Guardar juegos
  static Future<void> saveGames(List<Game> games) async {
    final prefs = await SharedPreferences.getInstance();
    final gamesData = games.map((game) => {
      'id': game.id,
      'name': game.name,
      'isCompleted': game.isCompleted,
      'isCurrent': game.isCurrent,
      'type': game.type.index,
      'hasTimer': game.hasTimer,
      'timerDuration': game.timerDuration,
    }).toList();
    await prefs.setString(_gamesKey, jsonEncode(gamesData));
  }

  // Cargar juegos
  static Future<List<Game>?> loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesString = prefs.getString(_gamesKey);
    if (gamesString == null) return null;
    try {
      final List<dynamic> gamesData = jsonDecode(gamesString);
      return gamesData.map((data) => Game(
        id: data['id'],
        name: data['name'],
        isCompleted: data['isCompleted'],
        isCurrent: data['isCurrent'],
        type: GameType.values[data['type']],
        hasTimer: data['hasTimer'] ?? false,
        timerDuration: data['timerDuration'] ?? 300,
      )).toList();
    } catch (e) {
      print('Error loading games: $e');
      return null;
    }
  }

  // Guardar historial de cambios
  static Future<void> saveScoreHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scoreHistoryKey, jsonEncode(history));
  }

  // Cargar historial de cambios
  static Future<List<Map<String, dynamic>>?> loadScoreHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_scoreHistoryKey);
    if (historyString == null) return null;
    try {
      final List<dynamic> historyData = jsonDecode(historyString);
      return historyData.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error loading score history: $e');
      return null;
    }
  }

  // Guardar configuración de numeración máxima
  static Future<void> saveMaxGridNumbers(int maxNumbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxGridNumbersKey, maxNumbers);
  }

  // Cargar configuración de numeración máxima
  static Future<int?> loadMaxGridNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxGridNumbersKey);
  }

  // Guardar estado de configuración
  static Future<void> saveConfigState(bool isConfigured) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_configStateKey, isConfigured);
  }

  // Cargar estado de configuración
  static Future<bool?> loadConfigState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_configStateKey);
  }

  // Guardar el estado del onboarding
  static Future<void> saveOnboardingState(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  // Cargar el estado del onboarding
  static Future<bool> loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Guardar programación (día)
  static Future<void> saveScheduleDay(String day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scheduleDayKey, day);
  }

  // Cargar programación (día)
  static Future<String?> loadScheduleDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scheduleDayKey);
  }

  // Guardar programación (tiempo en minutos)
  static Future<void> saveScheduleTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scheduleTimeKey, minutes);
  }

  // Cargar programación (tiempo en minutos)
  static Future<int?> loadScheduleTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scheduleTimeKey);
  }

  // Guardar estado de las notificaciones
  static Future<void> saveNotificationsState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Cargar estado de las notificaciones
  static Future<bool?> loadNotificationsState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey);
  }

  // Limpiar todos los datos guardados
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_teamsKey);
    await prefs.remove(_gamesKey);
    await prefs.remove(_maxGridNumbersKey);
    await prefs.remove(_configStateKey);
    await prefs.remove(_scoreHistoryKey);
    // No limpiamos la configuración de programación y notificaciones a propósito
  }
}