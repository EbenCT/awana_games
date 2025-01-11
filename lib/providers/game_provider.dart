// lib/providers/game_provider.dart
import 'package:flutter/foundation.dart';
import '../models/game.dart';

class GameProvider extends ChangeNotifier {
  final List<Game> _games = [];
  int _maxGridNumbers = 20; // Nuevo: controla el número máximo de la grilla
  List<int> _selectedNumbers = []; // Nuevo: mantiene los números seleccionados

  List<Game> get games => _games;
  int get maxGridNumbers => _maxGridNumbers; // Nuevo getter
  List<int> get selectedNumbers => _selectedNumbers; // Nuevo getter

  void addGame() {
    final nextGameIndex = _games.length + 1;
    _games.add(Game(
      id: nextGameIndex,
      name: 'Juego $nextGameIndex',
      type: GameType.normal,
    ));
    _selectedNumbers.clear(); // Limpiar números seleccionados al añadir nuevo juego
    notifyListeners();
  }

  void resetGames() {
    _games.clear();
    _selectedNumbers.clear();
    _maxGridNumbers = 20; // Resetear a 20 al iniciar nuevos juegos
    notifyListeners();
  }

  // Nuevo: método para incrementar el máximo de números
  void incrementMaxNumbers() {
    if (_maxGridNumbers < 50) {
      _maxGridNumbers += 1;
      notifyListeners();
    }
  }

  // Nuevo: método para actualizar números seleccionados
  void updateSelectedNumbers(List<int> numbers) {
    _selectedNumbers = numbers;
    notifyListeners();
  }
}