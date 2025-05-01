// lib/providers/game_provider.dart
import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  final List<Game> _games = [];
  int _maxGridNumbers = 20; // Controla el número máximo de la grilla
  List<int> _selectedNumbers = []; // Mantiene los números seleccionados
  bool _isLoading = false;
  bool _isInitialized = false;
  
  List<Game> get games => _games;
  int get maxGridNumbers => _maxGridNumbers;
  List<int> get selectedNumbers => _selectedNumbers;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  
  // Inicializar el proveedor y cargar datos guardados
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    
    try {
      // Cargar juegos guardados
      final savedGames = await StorageService.loadGames();
      if (savedGames != null && savedGames.isNotEmpty) {
        _games.clear();
        _games.addAll(savedGames);
      }
      
      // Cargar la configuración de número máximo
      final savedMaxNumbers = await StorageService.loadMaxGridNumbers();
      if (savedMaxNumbers != null) {
        _maxGridNumbers = savedMaxNumbers;
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing GameProvider: $e');
    } finally {
      _isLoading = false;
      // Nota: No llamamos a notifyListeners() aquí porque puede causar problemas durante la inicialización
    }
  }
  
  void addGame() {
    final nextGameIndex = _games.length + 1;
    _games.add(Game(
      id: nextGameIndex,
      name: 'Juego $nextGameIndex',
      type: GameType.normal,
    ));
    _selectedNumbers.clear(); // Limpiar números seleccionados al añadir nuevo juego
    _saveGames();
    notifyListeners();
  }
  
  void resetGames() {
    _games.clear();
    _selectedNumbers.clear();
    _maxGridNumbers = 20; // Resetear a 20 al iniciar nuevos juegos
    _saveGames();
    _saveMaxGridNumbers();
    notifyListeners();
  }
  
  // Método para incrementar el máximo de números
  void incrementMaxNumbers() {
    if (_maxGridNumbers < 50) {
      _maxGridNumbers += 1;
      _saveMaxGridNumbers();
      notifyListeners();
    }
  }
  
  // Método para actualizar números seleccionados
  void updateSelectedNumbers(List<int> numbers) {
    _selectedNumbers = numbers;
    notifyListeners();
  }
  
  void updateGameName(int gameIndex, String newName) {
    if (gameIndex >= 0 && gameIndex < _games.length) {
      // Nota: Como Game es inmutable, necesitamos crear una nueva instancia
      _games[gameIndex] = Game(
        id: _games[gameIndex].id,
        name: newName,
        type: _games[gameIndex].type,
        isCompleted: _games[gameIndex].isCompleted,
        isCurrent: _games[gameIndex].isCurrent,
      );
      _saveGames();
      notifyListeners();
    }
  }
  
  void updateGameType(int gameIndex, GameType type) {
    if (gameIndex >= 0 && gameIndex < _games.length) {
      _games[gameIndex] = Game(
        id: _games[gameIndex].id,
        name: _games[gameIndex].name,
        type: type,
        isCompleted: _games[gameIndex].isCompleted,
        isCurrent: _games[gameIndex].isCurrent,
      );
      _saveGames();
      notifyListeners();
    }
  }
  
  void markGameAsCompleted(int gameIndex) {
    if (gameIndex >= 0 && gameIndex < _games.length) {
      _games[gameIndex] = Game(
        id: _games[gameIndex].id,
        name: _games[gameIndex].name,
        type: _games[gameIndex].type,
        isCompleted: true,
        isCurrent: false,
      );
      _saveGames();
      notifyListeners();
    }
  }
  
  void setCurrentGame(int gameIndex) {
    for (int i = 0; i < _games.length; i++) {
      _games[i] = Game(
        id: _games[i].id,
        name: _games[i].name,
        type: _games[i].type,
        isCompleted: _games[i].isCompleted,
        isCurrent: i == gameIndex,
      );
    }
    _saveGames();
    notifyListeners();
  }
  
  // Métodos privados para guardar datos
  Future<void> _saveGames() async {
    try {
      await StorageService.saveGames(_games);
    } catch (e) {
      debugPrint('Error saving games: $e');
    }
  }
  
  Future<void> _saveMaxGridNumbers() async {
    try {
      await StorageService.saveMaxGridNumbers(_maxGridNumbers);
    } catch (e) {
      debugPrint('Error saving max grid numbers: $e');
    }
  }
}