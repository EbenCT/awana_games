// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/game.dart';
import 'package:flutter/material.dart';

class StorageService {
  static const String _teamsKey = 'teams';
  static const String _gamesKey = 'games';
  static const String _maxGridNumbersKey = 'maxGridNumbers';
  
  // Guardar equipos
  static Future<void> saveTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final teamsData = teams.map((team) => {
      'id': team.id,
      'name': team.name,
      'teamColor': team.teamColor.value,
      'totalScore': team.totalScore,
      'roundPoints': team.roundPoints,
      'gameScores': team.gameScores,
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
        roundPoints: data['roundPoints'],
        gameScores: List<int?>.from(data['gameScores']),
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
      )).toList();
    } catch (e) {
      print('Error loading games: $e');
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
  
  // Limpiar todos los datos guardados
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_teamsKey);
    await prefs.remove(_gamesKey);
    await prefs.remove(_maxGridNumbersKey);
  }
}