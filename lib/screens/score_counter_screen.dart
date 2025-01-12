// lib/screens/score_counter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/score_counter/edit_game_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teams = Provider.of<TeamsProvider>(context, listen: false).teams;
      for (var team in teams) {
        currentGameScores[team.id] = 0;
      }
    });
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
    showDialog(
      context: context,
      builder: (context) => EditGameDialog(
        game: game,
        gameIndex: Provider.of<GameProvider>(context, listen: false).games.length - 1,
      ),
    );
  }

  void _onGameTypeChanged(GameType type) {
    setState(() {
      activeGameType = type;
      selectedNumbers.clear();
    });
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
            final gameIndex = Provider.of<GameProvider>(context, listen: false).games.length - 1;
            teamsProvider.updateScore(teamId, gameIndex, points);
            assignedTeams.add(teamId);
          }
          
          // Encontrar el equipo restante y asignarle segundo lugar (75 puntos)
          final remainingTeam = teamsProvider.teams
              .firstWhere((team) => !selectedTeams.contains(team.id));
          _updateCurrentGameScore(remainingTeam.id, 75);
          teamsProvider.updateScore(remainingTeam.id, teamsProvider.teams.length - 1, 75);
          assignedTeams.add(remainingTeam.id);
          
          setState(() {
            allTeamsAssigned = true;
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
      final gameIndex = Provider.of<GameProvider>(context, listen: false).games.length - 1;
      teamsProvider.updateScore(teamId, gameIndex, points);
      assignedTeams.add(teamId);
    }

    final remainingTeams = teamsProvider.teams
        .where((team) => !assignedTeams.contains(team.id))
        .toList();

    if (currentStage == 2 && remainingTeams.length == 1) {
      // Si solo queda un equipo después de asignar el segundo lugar
      _updateCurrentGameScore(remainingTeams.first.id, 50);
      final gameIndex = Provider.of<GameProvider>(context, listen: false).games.length - 1;
      teamsProvider.updateScore(remainingTeams.first.id, gameIndex, 50);
      assignedTeams.add(remainingTeams.first.id);
      setState(() {
        allTeamsAssigned = true;
      });
    } else if (currentStage == 3 || (currentStage == 2 && remainingTeams.length == 1)) {
      if (remainingTeams.length == 1) {
        _updateCurrentGameScore(remainingTeams.first.id, 25);
        final gameIndex = Provider.of<GameProvider>(context, listen: false).games.length - 1;
        teamsProvider.updateScore(remainingTeams.first.id, gameIndex, 25);
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

  void _resetGame(GameProvider gameProvider) {
  gameProvider.addGame();
  setState(() {
    currentStage = 1;
    selectedTeams.clear();
    assignedTeams.clear();
    allTeamsAssigned = false;
    roundCalculated = false;
    // Resetear puntajes del juego actual
    currentGameScores.clear();
    final teams = Provider.of<TeamsProvider>(context, listen: false).teams;
    for (var team in teams) {
      currentGameScores[team.id] = 0;
      Provider.of<TeamsProvider>(context, listen: false)
          .updateTeamRoundPoints(team.id, 0);
    }
    // Limpiar números seleccionados pero mantener el máximo de la grilla
    selectedNumbers.clear();
  });
}

  void _calculateRoundResults(TeamsProvider teamsProvider, GameProvider gameProvider) {
    // Ordenar equipos por puntuación actual
    final List<Team> sortedTeams = List.from(teamsProvider.teams)
      ..sort((a, b) => b.roundPoints.compareTo(a.roundPoints));

    int currentRank = 1;
    int currentScore = sortedTeams[0].roundPoints;
    Map<int, int> pointsForRank = {1: 100, 2: 75, 3: 50, 4: 25};

    // Obtener el índice del juego actual
    final gameIndex = gameProvider.games.length - 1;

    for (int i = 0; i < sortedTeams.length; i++) {
      if (sortedTeams[i].roundPoints < currentScore) {
        currentRank = i + 1;
        currentScore = sortedTeams[i].roundPoints;
      }
      
      final points = pointsForRank[currentRank] ?? 25;
      _updateCurrentGameScore(sortedTeams[i].id, points);
      teamsProvider.updateScore(
        sortedTeams[i].id,
        gameIndex,
        points
      );
    }

    setState(() {
      roundCalculated = true;
      allTeamsAssigned = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final currentGame = gameProvider.games.isNotEmpty ? gameProvider.games.last : null;

    return Scaffold(
      appBar: GameAppBar(
        currentGame: currentGame,
        onEditGame: () => _showEditGameNameDialog(context, currentGame!),
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
                ),
                const SizedBox(height: 16),
                if (activeGameType == GameType.normal)
                  Text(
                    _getStageText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
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
              onTeamRoundPointsChanged: (teamId, change) {
                setState(() {               
                  final team = teamsProvider.teams.firstWhere((t) => t.id == teamId);
                  final int  newPoints = team.roundPoints + change;
                  if (newPoints >= 0) {
                    teamsProvider.updateTeamRoundPoints(teamId, newPoints);
                  }
                });
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
        onNextGame: () => _resetGame(gameProvider),
      ),
    );
  }
}