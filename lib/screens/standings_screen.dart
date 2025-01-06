// lib/screens/standings_screen.dart
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late List<Game> games;
  late List<Team> teams;
  int currentGameIndex = 2; // Índice del juego actual

  @override
  void initState() {
    super.initState();
    games = [
      Game(id: 1, name: 'Tumbando el Pin', type: GameType.rounds, isCompleted: true),
      Game(id: 2, name: 'Carrera de Relevos', type: GameType.normal, isCompleted: true),
      Game(id: 3, name: 'Juego de Memoria', type: GameType.normal, isCurrent: true),
      Game(id: 4, name: 'Búsqueda del Tesoro', type: GameType.normal),
      Game(id: 5, name: 'Competencia Final', type: GameType.rounds),
    ];

    teams = [
      Team(
        id: 1,
        name: 'Rojo',
        teamColor: Colors.red,
        totalScore: 275,
        gameScores: [100, 75, null, null, null],
      ),
      Team(
        id: 2,
        name: 'Amarillo',
        teamColor: Colors.amber,
        totalScore: 200,
        gameScores: [75, 50, null, null, null],
      ),
      Team(
        id: 3,
        name: 'Verde',
        teamColor: Colors.green,
        totalScore: 150,
        gameScores: [50, 75, null, null, null],
      ),
      Team(
        id: 4,
        name: 'Azul',
        teamColor: Colors.blue,
        totalScore: 125,
        gameScores: [25, 25, null, null, null],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Posiciones'),
      ),
      body: Column(
        children: [
          _buildGameNavigator(),
          _buildGameProgress(),
          Expanded(
            child: _buildStandingsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameNavigator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentGameIndex > 0
                ? () => setState(() => currentGameIndex--)
                : null,
          ),
          Column(
            children: [
              const Text(
                'Juego Actual',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                games[currentGameIndex].name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentGameIndex < games.length - 1
                ? () => setState(() => currentGameIndex++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGameProgress() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: game.isCurrent
                  ? Colors.purple[100]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: game.isCurrent
                  ? Border.all(color: Colors.purple, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  game.isCompleted
                      ? 'Completado'
                      : game.isCurrent
                          ? 'En Curso'
                          : 'Pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStandingsTable() {
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Pos')),
            const DataColumn(label: Text('Equipo')),
            ...List.generate(
              games.length,
              (index) => DataColumn(
                label: Text('Juego ${index + 1}'),
              ),
            ),
            const DataColumn(label: Text('Total')),
          ],
          rows: sortedTeams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index == 0) 
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      Text('${index + 1}°'),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: team.teamColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(team.name),
                    ],
                  ),
                ),
                ...team.gameScores.map((score) => DataCell(
                  Text(score?.toString() ?? '-'),
                )),
                DataCell(
                  Text(
                    '${team.totalScore}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}