
// lib/models/game.dart
class Game {
  final int id;
  final String name;
  final bool isCompleted;
  final bool isCurrent;
  final GameType type;
  final bool hasTimer; // Nuevo campo
  final int timerDuration; // Nuevo campo en segundos

  Game({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.isCurrent = false,
    required this.type,
    this.hasTimer = false, // Por defecto, sin temporizador
    this.timerDuration = 300, // Por defecto 5 minutos
  });
}

enum GameType {
  normal,
  rounds
}