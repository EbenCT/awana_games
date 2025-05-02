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
  bool _isConfigured = false; // Indica si la configuración inicial se ha completado

  List<Game> get games => _games;
  int get maxGridNumbers => _maxGridNumbers;
  List<int> get selectedNumbers => _selectedNumbers;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isConfigured => _isConfigured;
  
  // Obtener el índice del juego actual
  int get currentGameIndex {
    final currentIndex = _games.indexWhere((game) => game.isCurrent);
    return currentIndex >= 0 ? currentIndex : 0;
  }
  
  // Obtener el juego actual
  Game? get currentGame {
    if (_games.isEmpty) return null;
    final currentIndex = _games.indexWhere((game) => game.isCurrent);
    return currentIndex >= 0 ? _games[currentIndex] : _games.first;
  }

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
        
        // Si no hay juego marcado como actual, marcar el primero
        if (!_games.any((game) => game.isCurrent)) {
          _setGameAsCurrent(0);
        }
        
        _isConfigured = true; // Si hay juegos guardados, consideramos que está configurado
      }
      
      // Cargar la configuración de número máximo
      final savedMaxNumbers = await StorageService.loadMaxGridNumbers();
      if (savedMaxNumbers != null) {
        _maxGridNumbers = savedMaxNumbers;
      }
      
      // Cargar estado de configuración
      final configState = await StorageService.loadConfigState();
      if (configState != null) {
        _isConfigured = configState;
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing GameProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para configurar inicialmente los juegos
  void configureGames(List<String> gameNames) {
    _games.clear();
    
    for (int i = 0; i < gameNames.length; i++) {
      if (gameNames[i].isNotEmpty) {
        _games.add(Game(
          id: i + 1,
          name: gameNames[i],
          type: GameType.normal, // Por defecto todos son juegos normales
          isCompleted: false,
          isCurrent: i == 0, // El primer juego es el actual
        ));
      }
    }
    
    _isConfigured = true;
    _saveGames();
    _saveConfigState();
    notifyListeners();
  }

  // Añadir un nuevo juego
  void addGame() {
    final nextGameIndex = _games.length + 1;
    _games.add(Game(
      id: nextGameIndex,
      name: 'Juego $nextGameIndex',
      type: GameType.normal,
      isCurrent: _games.isEmpty, // Si es el primer juego, marcarlo como actual
    ));

    _selectedNumbers.clear(); // Limpiar números seleccionados al añadir nuevo juego
    _saveGames();
    notifyListeners();
  }

  // Añadir un juego extra (al final)
  void addExtraGame(String name) {
    final nextGameIndex = _games.length + 1;
    final newGame = Game(
      id: nextGameIndex,
      name: name.isNotEmpty ? name : 'Juego Extra $nextGameIndex',
      type: GameType.normal,
      isCompleted: false,
      isCurrent: false, // No es el actual todavía
    );
    
    _games.add(newGame);
    _saveGames();
    notifyListeners();
  }

  void resetGames() {
    _games.clear();
    _selectedNumbers.clear();
    _maxGridNumbers = 20; // Resetear a 20 al iniciar nuevos juegos
    _isConfigured = false; // Resetear el estado de configuración
    _saveGames();
    _saveMaxGridNumbers();
    _saveConfigState();
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

  // Solo marca el juego como completado sin cambiar el juego actual
  void markGameAsCompleted(int gameIndex) {
    if (gameIndex >= 0 && gameIndex < _games.length) {
      _games[gameIndex] = Game(
        id: _games[gameIndex].id,
        name: _games[gameIndex].name,
        type: _games[gameIndex].type,
        isCompleted: true,
        isCurrent: _games[gameIndex].isCurrent, // Mantiene su estado actual
      );
      
      _saveGames();
      notifyListeners();
    }
  }

  // Avanzar manualmente al siguiente juego
  bool moveToNextGame() {
    final currentIndex = _games.indexWhere((game) => game.isCurrent);
    
    if (currentIndex >= 0 && currentIndex < _games.length - 1) {
      // Marcar el juego actual como completado y no actual
      _games[currentIndex] = Game(
        id: _games[currentIndex].id,
        name: _games[currentIndex].name,
        type: _games[currentIndex].type,
        isCompleted: true,
        isCurrent: false,
      );
      
      // Establecer el siguiente juego como actual
      _games[currentIndex + 1] = Game(
        id: _games[currentIndex + 1].id,
        name: _games[currentIndex + 1].name,
        type: _games[currentIndex + 1].type,
        isCompleted: false,
        isCurrent: true,
      );
      
      _saveGames();
      notifyListeners();
      return true; // Indica que se pudo avanzar
    }
    
    return false; // No hay más juegos
  }

  // Método privado para establecer un juego como actual
  void _setGameAsCurrent(int gameIndex) {
    if (gameIndex >= 0 && gameIndex < _games.length) {
      for (int i = 0; i < _games.length; i++) {
        _games[i] = Game(
          id: _games[i].id,
          name: _games[i].name,
          type: _games[i].type,
          isCompleted: _games[i].isCompleted,
          isCurrent: i == gameIndex,
        );
      }
    }
  }

  // Establecer explícitamente el juego actual (método público)
  void setCurrentGame(int gameIndex) {
    _setGameAsCurrent(gameIndex);
    _saveGames();
    notifyListeners();
  }

  // Verificar si hay más juegos después del actual
  bool hasNextGame() {
    final currentIndex = _games.indexWhere((game) => game.isCurrent);
    return currentIndex >= 0 && currentIndex < _games.length - 1;
  }
  
  // Verificar si hay juegos anteriores al actual
  bool hasPreviousGame() {
    final currentIndex = _games.indexWhere((game) => game.isCurrent);
    return currentIndex > 0;
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
  
  Future<void> _saveConfigState() async {
    try {
      await StorageService.saveConfigState(_isConfigured);
    } catch (e) {
      debugPrint('Error saving config state: $e');
    }
  }
}