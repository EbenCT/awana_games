import 'package:flutter/foundation.dart';
import '../models/game.dart';

class GameProvider extends ChangeNotifier {
  final List<Game> _games = [];

  List<Game> get games => _games;

  void addGame() {
    final nextGameIndex = _games.length + 1;
    _games.add(Game(
      id: nextGameIndex,
      name: 'Juego $nextGameIndex',
      type: GameType.normal,
    ));
    notifyListeners();
  }

  void resetGames() {
    _games.clear();
    notifyListeners();
  }
}
