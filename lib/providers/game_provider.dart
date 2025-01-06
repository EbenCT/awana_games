// lib/providers/game_provider.dart
import 'package:flutter/foundation.dart';
import '../models/game.dart';

class GameProvider extends ChangeNotifier {
  List<Game> _games = [];
  int _currentGameIndex = 0;
  
  List<Game> get games => _games;
  Game get currentGame => _games[_currentGameIndex];
  int get currentGameIndex => _currentGameIndex;

  void initializeGames(List<Game> games) {
    _games = games;
    notifyListeners();
  }

  void moveToNextGame() {
    if (_currentGameIndex < _games.length - 1) {
      _currentGameIndex++;
      notifyListeners();
    }
  }

  void moveToPreviousGame() {
    if (_currentGameIndex > 0) {
      _currentGameIndex--;
      notifyListeners();
    }
  }

  void completeCurrentGame() {
    _games[_currentGameIndex] = Game(
      id: currentGame.id,
      name: currentGame.name,
      isCompleted: true,
      type: currentGame.type,
    );
    notifyListeners();
  }
}