// lib/screens/score_counter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../widgets/common/score_card.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/score_counter/game_type_selector.dart';
import '../widgets/score_counter/number_grid.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';

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
  Map<int, int> currentGameScores = {};  // New map to track current game scores

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize current game scores
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
            teamsProvider.updateScore(teamId, teamsProvider.teams.length - 1, points);
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
      teamsProvider.updateScore(teamId, teamsProvider.teams.length - 1, points);
      assignedTeams.add(teamId);
    }

    final remainingTeams = teamsProvider.teams
        .where((team) => !assignedTeams.contains(team.id))
        .toList();

    if (currentStage == 2 && remainingTeams.length == 1) {
      // Si solo queda un equipo después de asignar el segundo lugar
      _updateCurrentGameScore(remainingTeams.first.id, 50);
      teamsProvider.updateScore(remainingTeams.first.id, teamsProvider.teams.length - 1, 50);
      assignedTeams.add(remainingTeams.first.id);
      setState(() {
        allTeamsAssigned = true;
      });
    } else if (currentStage == 3 || (currentStage == 2 && remainingTeams.length == 1)) {
      if (remainingTeams.length == 1) {
        _updateCurrentGameScore(remainingTeams.first.id, 25);
        teamsProvider.updateScore(remainingTeams.first.id, teamsProvider.teams.length - 1, 25);
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
      // Resetear puntajes del juego actual
      currentGameScores.clear();
      final teams = Provider.of<TeamsProvider>(context, listen: false).teams;
      for (var team in teams) {
        currentGameScores[team.id] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final currentGame = gameProvider.games.isNotEmpty ? gameProvider.games.last : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(currentGame?.name ?? 'Sin Juego'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.pushNamed(context, '/standings'),
          ),
        ],
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...teamsProvider.teams.map((team) {
                  final isDisabled = assignedTeams.contains(team.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ScoreCard(
                      team: team,
                      showRoundPoints: activeGameType == GameType.rounds,
                      onPointsChanged: activeGameType == GameType.rounds
                          ? (change) => teamsProvider.updateTeamRoundPoints(team.id, change)
                          : null,
                      isSelected: selectedTeams.contains(team.id),
                      onSelected: isDisabled
                          ? null
                          : (isSelected) {
                              setState(() {
                                if (isSelected) {
                                  selectedTeams.add(team.id);
                                } else {
                                  selectedTeams.remove(team.id);
                                }
                              });
                            },
                      currentGameScore: currentGameScores[team.id] ?? 0,  // Add current game score
                    ),
                  );
                }),
                if (activeGameType == GameType.rounds) ...[
                  const SizedBox(height: 16),
                  NumberGrid(
                    selectedNumbers: selectedNumbers,
                    onNumberSelected: _onNumberSelected,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activeGameType == GameType.normal)
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: PrimaryButton(
                    text: 'Asignar Posición',
                    onPressed: selectedTeams.isNotEmpty && !allTeamsAssigned
                        ? () => _assignPoints(teamsProvider)
                        : (){},
                    backgroundColor: Colors.green,
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, // Ocupa todo el ancho disponible
                child: PrimaryButton(
                  text: 'Próximo Juego',
                  onPressed: allTeamsAssigned ? () => _resetGame(gameProvider) : (){},
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}