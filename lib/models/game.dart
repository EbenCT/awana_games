
// lib/models/game.dart
class Game {
  final int id;
  final String name;
  final bool isCompleted;
  final bool isCurrent;
  final GameType type;

  Game({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.isCurrent = false,
    required this.type,
  });
}

enum GameType {
  normal,
  rounds
}