// lib/screens/score_counter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/common/edit_game_dialog.dart';
import '../widgets/score_counter/game_app_bar.dart';
import '../widgets/score_counter/game_body.dart';
import '../widgets/score_counter/game_bottom_bar.dart';
import '../widgets/score_counter/game_type_selector.dart';

class ScoreCounterScreen extends StatefulWidget {
  const ScoreCounterScreen({Key? key}) : super(key: key);

  @override
  State<ScoreCounterScreen> createState() => _ScoreCounterScreenState();
}

class _ScoreCounterScreenState extends State<ScoreCounterScreen> {
  GameType activeGameType = GameType.normal;
  List<int> selectedNumbers = [];
  int currentStage = 1;
  List<int> selectedTeams = [];
  List<int> assignedTeams = [];
  bool allTeamsAssigned = false;
  bool roundCalculated = false;
  Map<int, int> currentGameScores = {};
  Map<int, int> currentRoundPoints = {}; // Para mantener los puntos por rondas del juego actual
  bool lockGameTypeSelector = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teams = Provider.of<TeamsProvider>(context, listen: false).teams;
      for (var team in teams) {
        currentGameScores[team.id] = 0;
        currentRoundPoints[team.id] = 0; // Inicializar puntos por rondas
      }
      
      // Inicializar el tipo de juego según el juego actual
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.currentGame != null) {
        setState(() {
          activeGameType = gameProvider.currentGame!.type;
        });
      }
      
      // Verificar si ya hay puntajes asignados para este juego
      _checkIfScoresAlreadyAssigned();
    });
  }
  
  // Método para verificar si ya hay puntajes asignados en el juego actual
  void _checkIfScoresAlreadyAssigned() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final gameIndex = gameProvider.currentGameIndex;
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    
    // Verificar si algún equipo ya tiene puntuación para este juego
    bool anyTeamHasScore = false;
    for (var team in teamsProvider.teams) {
      // Verificar puntuaciones de juego
      if (team.gameScores.length > gameIndex && team.gameScores[gameIndex] != null) {
        anyTeamHasScore = true;
        
        // Actualizar los puntajes actuales para mostrarlos en la UI
        currentGameScores[team.id] = team.gameScores[gameIndex] ?? 0;
        
        // Si al menos un equipo tiene puntaje, verificamos si todos están asignados
        if (team.gameScores[gameIndex] != null && team.gameScores[gameIndex]! > 0) {
          assignedTeams.add(team.id);
        }
      }
      
      // Verificar puntos por rondas
      if (team.roundPoints.length > gameIndex && team.roundPoints[gameIndex] != null) {
        // Actualizar los puntos por rondas actuales
        currentRoundPoints[team.id] = team.roundPoints[gameIndex] ?? 0;
        
        // Si hay puntos por rondas y es un juego tipo rondas, marcar como calculado
        if (activeGameType == GameType.rounds && team.roundPoints[gameIndex]! > 0) {
          roundCalculated = true;
        }
      }
    }
    
    // Si hay al menos un equipo con puntaje, bloqueamos el selector de tipo de juego
    if (anyTeamHasScore) {
      setState(() {
        lockGameTypeSelector = true;
        
        // Si todos los equipos tienen puntaje, el juego está completado
        if (assignedTeams.length == teamsProvider.teams.length) {
          allTeamsAssigned = true;
        }
      });
    }
  }

  String _getStageText() {
    switch (currentStage) {
      case 1:
        return "¿Qué equipo/s quedó en primer lugar?";
      case 2:
        return "¿Qué equipo/s quedó en segundo lugar?";
      case 3:
        return "¿Qué equipo/s quedó en tercer lugar?";
      default:
        return "";
    }
  }

  void _showEditGameNameDialog(BuildContext context, Game game) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => EditGameDialog(
        game: game,
        gameIndex: gameProvider.currentGameIndex,
      ),
    );
  }

  void _onGameTypeChanged(GameType type) {
    // Solo permitir cambiar el tipo si no hay puntuaciones asignadas
    if (!lockGameTypeSelector) {
      setState(() {
        activeGameType = type;
        selectedNumbers.clear();
      });
      
      // Actualizar el tipo de juego en el provider
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.currentGame != null) {
        gameProvider.updateGameType(gameProvider.currentGameIndex, type);
      }
    } else {
      // Mostrar mensaje informando que no se puede cambiar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede cambiar el tipo de juego cuando ya hay puntuaciones asignadas.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onNumberSelected(int number) {
    setState(() {
      selectedNumbers.add(number);
    });
  }

  void _updateCurrentGameScore(int teamId, int points) {
    setState(() {
      currentGameScores[teamId] = points;
    });
  }

  void _assignPoints(TeamsProvider teamsProvider) {
    int points = 0;
    switch (currentStage) {
      case 1:
        points = 100;
        if (selectedTeams.length == 3) {
          // Si hay 3 equipos en primer lugar
          for (var teamId in selectedTeams) {
            _updateCurrentGameScore(teamId, points);
            final gameProvider = Provider.of<GameProvider>(context, listen: false);
            teamsProvider.updateScore(teamId, gameProvider.currentGameIndex, points);
            assignedTeams.add(teamId);
          }
          
          // Encontrar el equipo restante y asignarle segundo lugar (75 puntos)
          final remainingTeam = teamsProvider.teams
              .firstWhere((team) => !selectedTeams.contains(team.id));
          _updateCurrentGameScore(remainingTeam.id, 75);
          final gameProvider = Provider.of<GameProvider>(context, listen: false);
          teamsProvider.updateScore(remainingTeam.id, gameProvider.currentGameIndex, 75);
          assignedTeams.add(remainingTeam.id);
          
          setState(() {
            allTeamsAssigned = true;
            lockGameTypeSelector = true; // Bloquear cambio de tipo de juego
          });
          return;
        }
        break;
      case 2:
        points = 75;
        break;
      case 3:
        points = 50;
        break;
    }
    
    // Asignar puntos a los equipos seleccionados
    for (var teamId in selectedTeams) {
      _updateCurrentGameScore(teamId, points);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      teamsProvider.updateScore(teamId, gameProvider.currentGameIndex, points);
      assignedTeams.add(teamId);
      
      // Bloquear cambio de tipo de juego en cuanto se asigna la primera puntuación
      if (!lockGameTypeSelector) {
        setState(() {
          lockGameTypeSelector = true;
        });
      }
    }
    
    final remainingTeams = teamsProvider.teams
        .where((team) => !assignedTeams.contains(team.id))
        .toList();
    
    if (currentStage == 2 && remainingTeams.length == 1) {
      // Si solo queda un equipo después de asignar el segundo lugar
      _updateCurrentGameScore(remainingTeams.first.id, 50);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      teamsProvider.updateScore(remainingTeams.first.id, gameProvider.currentGameIndex, 50);
      assignedTeams.add(remainingTeams.first.id);
      
      setState(() {
        allTeamsAssigned = true;
      });
    } else if (currentStage == 3 || (currentStage == 2 && remainingTeams.length == 1)) {
      if (remainingTeams.length == 1) {
        _updateCurrentGameScore(remainingTeams.first.id, 25);
        final gameProvider = Provider.of<GameProvider>(context, listen: false);
        teamsProvider.updateScore(remainingTeams.first.id, gameProvider.currentGameIndex, 25);
        assignedTeams.add(remainingTeams.first.id);
      }
    }
    
    // Verificar si todos los equipos tienen puntaje asignado
    if (assignedTeams.length == 4) {
      setState(() {
        allTeamsAssigned = true;
      });
    }
    
    // Avanzar al siguiente paso
    setState(() {
      if (currentStage < 3 && !allTeamsAssigned) {
        currentStage++;
      }
      selectedTeams.clear();
    });
  }

  void _calculateRoundResults(TeamsProvider teamsProvider, GameProvider gameProvider) {
    // Ordenar equipos por puntuación actual de ronda
    final gameIndex = gameProvider.currentGameIndex;
    
    final List<Team> sortedTeams = List.from(teamsProvider.teams)
      ..sort((a, b) {
        final aPoints = currentRoundPoints[a.id] ?? 0;
        final bPoints = currentRoundPoints[b.id] ?? 0;
        return bPoints.compareTo(aPoints);
      });
    
    int currentRank = 1;
    int currentScore = currentRoundPoints[sortedTeams[0].id] ?? 0;
    Map<int, int> pointsForRank = {1: 100, 2: 75, 3: 50, 4: 25};
    
    for (int i = 0; i < sortedTeams.length; i++) {
      final teamRoundPoints = currentRoundPoints[sortedTeams[i].id] ?? 0;
      
      if (teamRoundPoints < currentScore) {
        currentRank = i + 1;
        currentScore = teamRoundPoints;
      }
      
      final points = pointsForRank[currentRank] ?? 25;
      final teamId = sortedTeams[i].id;
      
      // Actualizar puntuación del juego
      _updateCurrentGameScore(teamId, points);
      teamsProvider.updateScore(teamId, gameIndex, points);
      
      // Guardar también los puntos por rondas para este juego
      teamsProvider.updateTeamRoundPoints(teamId, gameIndex, currentRoundPoints[teamId] ?? 0);
      
      // Añadir a equipos asignados
      assignedTeams.add(teamId);
    }
    
    setState(() {
      roundCalculated = true;
      allTeamsAssigned = true;
      lockGameTypeSelector = true; // Bloquear cambio de tipo de juego
    });
  }

  // Método para actualizar los puntos de ronda de un equipo
  void _updateTeamRoundPoints(int teamId, int change) {
    final currentPoints = currentRoundPoints[teamId] ?? 0;
    final newPoints = currentPoints + change;
    
    if (newPoints >= 0) {
      setState(() {
        currentRoundPoints[teamId] = newPoints;
      });
    }
  }

  // Método para finalizar el juego actual y pasar al siguiente
  void _nextGame(GameProvider gameProvider) {
    // Obtener el índice actual antes de los cambios
    final currentIndex = gameProvider.currentGameIndex;
    
    // Marcar el juego actual como completado (sin cambiar el juego actual)
    gameProvider.markGameAsCompleted(currentIndex);
    
    // Verificar si hay más juegos
    if (gameProvider.hasNextGame()) {
      // Avanzar manualmente al siguiente juego en el provider
      if (gameProvider.moveToNextGame()) {
        // Reiniciar el estado del juego para el nuevo juego
        setState(() {
          currentStage = 1;
          selectedTeams.clear();
          assignedTeams.clear();
          allTeamsAssigned = false;
          roundCalculated = false;
          lockGameTypeSelector = false; // Permitir cambiar el tipo en el nuevo juego
          
          // Resetear puntajes del juego actual
          currentGameScores.clear();
          currentRoundPoints.clear(); // Limpiar puntos por rondas
          final teams = Provider.of<TeamsProvider>(context, listen: false).teams;
          for (var team in teams) {
            currentGameScores[team.id] = 0;
            currentRoundPoints[team.id] = 0; // Inicializar puntos por rondas
          }
          
          // Limpiar números seleccionados pero mantener el máximo de la grilla
          selectedNumbers.clear();
          
          // Actualizar el tipo de juego según el nuevo juego actual
          if (gameProvider.currentGame != null) {
            activeGameType = gameProvider.currentGame!.type;
          }
        });
        
        // Verificar si el nuevo juego ya tiene puntuaciones asignadas
        _checkIfScoresAlreadyAssigned();
      }
    } else {
      // Si no hay más juegos, ir a la tabla de posiciones
      Navigator.of(context).pushReplacementNamed('/standings');
    }
  }

  // Mostrar el diálogo para agregar un juego extra
  void _showAddExtraGameDialog() {
    final TextEditingController controller = TextEditingController(text: 'Juego Extra');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Juego Extra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Añadirás un juego extra al final de la lista. El juego actual se mantendrá como último hasta que lo finalices.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del juego extra',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Añadir el juego extra
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              gameProvider.addExtraGame(controller.text.trim());
              Navigator.pop(context);
              
              // Mostrar mensaje de confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Juego extra añadido correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final currentGame = gameProvider.currentGame;
    final isLastGame = !gameProvider.hasNextGame();
    
    return WillPopScope(
      // Evitar que se pueda volver atrás con el botón físico
      onWillPop: () async => false,
      child: Scaffold(
        appBar: GameAppBar(
          currentGame: currentGame,
          onEditGame: currentGame != null ? () => _showEditGameNameDialog(context, currentGame) : null,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GameTypeSelector(
                    selectedType: activeGameType,
                    onTypeSelected: _onGameTypeChanged,
                    isDisabled: lockGameTypeSelector, // Usamos la variable para controlar si se puede cambiar
                  ),
                  const SizedBox(height: 16),
                  if (activeGameType == GameType.normal)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Contorno del texto con duplicados
                        Text(
                          _getStageText(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 6
                              ..color = Colors.black, // Contorno negro
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Texto principal encima del contorno
                        Text(
                          _getStageText(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.yellow, // Color principal
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: GameBody(
                teams: teamsProvider.teams,
                activeGameType: activeGameType,
                assignedTeams: assignedTeams,
                selectedTeams: selectedTeams,
                currentGameScores: currentGameScores,
                roundCalculated: roundCalculated,
                currentRoundPoints: currentRoundPoints, // Pasar los puntos por rondas actuales
                onTeamRoundPointsChanged: (teamId, change) {
                  _updateTeamRoundPoints(teamId, change);
                },
                onTeamSelected: (teamId, isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedTeams.add(teamId);
                    } else {
                      selectedTeams.remove(teamId);
                    }
                  });
                },
                selectedNumbers: selectedNumbers,
                onNumberSelected: _onNumberSelected,
                maxGridNumbers: gameProvider.maxGridNumbers,
                onAddNumber: () => gameProvider.incrementMaxNumbers(),
                gameIndex: gameProvider.currentGameIndex, // Pasar el índice del juego actual
              ),
            ),
          ],
        ),
        bottomNavigationBar: GameBottomBar(
          activeGameType: activeGameType,
          roundCalculated: roundCalculated,
          allTeamsAssigned: allTeamsAssigned,
          hasSelectedTeams: selectedTeams.isNotEmpty,
          onAssignPosition: () => _assignPoints(teamsProvider),
          onCalculateResult: () => _calculateRoundResults(teamsProvider, gameProvider),
          onNextGame: () => _nextGame(gameProvider),
          isLastGame: isLastGame,
          onAddExtraGame: isLastGame ? _showAddExtraGameDialog : null,
        ),
      ),
    );
  }
}