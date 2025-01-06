// lib/screens/game_rounds_screen.dart
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../widgets/common/score_card.dart';
import '../widgets/score_counter/number_grid.dart';

class GameRoundsScreen extends StatefulWidget {
  const GameRoundsScreen({Key? key}) : super(key: key);

  @override
  State<GameRoundsScreen> createState() => _GameRoundsScreenState();
}

class _GameRoundsScreenState extends State<GameRoundsScreen> {
  late List<Team> teams;
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

  void _onNumberSelected(int number) {
    if (!selectedNumbers.contains(number)) {
      setState(() {
        selectedNumbers.add(number);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego por Rondas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...teams.map((team) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ScoreCard(
                  team: team,
                  showRoundPoints: true,
                  onPointsChanged: (change) {
                    setState(() {
                      team.roundPoints += change;
                    });
                  },
                ),
              )),
          const SizedBox(height: 16),
          NumberGrid(
            selectedNumbers: selectedNumbers,
            onNumberSelected: _onNumberSelected,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Números seleccionados: ${selectedNumbers.length}/20',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Implementar lógica para finalizar ronda
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Finalizar Ronda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}