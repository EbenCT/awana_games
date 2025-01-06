// lib/screens/score_counter_screen.dart
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../widgets/common/score_card.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/score_counter/game_type_selector.dart';
import '../widgets/score_counter/number_grid.dart';

class ScoreCounterScreen extends StatefulWidget {
  const ScoreCounterScreen({Key? key}) : super(key: key);

  @override
  State<ScoreCounterScreen> createState() => _ScoreCounterScreenState();
}

class _ScoreCounterScreenState extends State<ScoreCounterScreen> {
  late List<Team> teams;
  GameType activeGameType = GameType.normal;
  List<int> selectedNumbers = [];

  @override
  void initState() {
    super.initState();
    teams = [
      Team(id: 1, name: 'Rojo', teamColor: Colors.red),
      Team(id: 2, name: 'Amarillo', teamColor: Colors.amber),
      Team(id: 3, name: 'Verde', teamColor: Colors.green),
      Team(id: 4, name: 'Azul', teamColor: Colors.blue),
    ];
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

  void _updateTeamRoundPoints(Team team, int change) {
    setState(() {
      final index = teams.indexWhere((t) => t.id == team.id);
      if (index != -1) {
        teams[index] = team.copyWith(
          roundPoints: team.roundPoints + change,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador de Puntos'),
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
            child: GameTypeSelector(
              selectedType: activeGameType,
              onTypeSelected: _onGameTypeChanged,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...teams.map((team) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ScoreCard(
                    team: team,
                    showRoundPoints: activeGameType == GameType.rounds,
                    onPointsChanged: activeGameType == GameType.rounds
                        ? (change) => _updateTeamRoundPoints(team, change)
                        : null,
                  ),
                )),
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
              if (activeGameType == GameType.rounds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Números seleccionados: ${selectedNumbers.length}/20',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                children: [
                  if (activeGameType == GameType.rounds)
                    Expanded(
                      child: PrimaryButton(
                        text: 'Finalizar Ronda',
                        onPressed: () {
                          // Implementar lógica de finalización de ronda
                        },
                        backgroundColor: Colors.purple,
                      ),
                    )
                  else ...[
                    Expanded(
                      child: PrimaryButton(
                        text: 'Asignar Posiciones',
                        onPressed: () {
                          // Implementar asignación de posiciones
                        },
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Siguiente Juego',
                        onPressed: () {
                          // Implementar cambio de juego
                        },
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}