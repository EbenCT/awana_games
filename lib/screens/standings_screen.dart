import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../config/constants.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late List<Game> games;
  late List<Team> teams;
  int currentGameIndex = 2;

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
        totalScore: 0,
        gameScores: [100, 75, null, null, null],
      ),
      Team(
        id: 2,
        name: 'Amarillo',
        teamColor: Colors.amber,
        totalScore: 0,
        gameScores: [75, 50, null, null, null],
      ),
      Team(
        id: 3,
        name: 'Verde',
        teamColor: Colors.green,
        totalScore: 0,
        gameScores: [50, 75, null, null, null],
      ),
      Team(
        id: 4,
        name: 'Azul',
        teamColor: Colors.blue,
        totalScore: 0,
        gameScores: [25, 25, null, null, null],
      ),
    ];

    _calculateTotals();
  }

  void _calculateTotals() {
    for (var team in teams) {
      team.totalScore = team.gameScores
          .where((score) => score != null)
          .fold(0, (sum, score) => sum + (score ?? 0));
    }
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

  Widget _buildStandingsTable() {
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    final List<DataRow> dataRows = [
      for (int i = 0; i < AppConstants.totalGames; i++)
        DataRow(
          cells: [
            DataCell(SizedBox(
              width: 60, // Ajusta el ancho mínimo de la celda
              child: Text(
                'Juego ${i + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
            ...sortedTeams.map((team) => DataCell(
                  Container(
                    width: 60, // Ajusta el ancho de las celdas de equipos
                    color: team.teamColor.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: Text(
                      team.gameScores[i]?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ],
        ),
      DataRow(
        cells: [
          const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
          ...sortedTeams.map((team) => DataCell(
                Container(
                  width: 60,
                  color: team.teamColor.withOpacity(0.4),
                  alignment: Alignment.center,
                  child: Text(
                    '${team.totalScore}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Pos', style: TextStyle(fontWeight: FontWeight.bold))),
          ...sortedTeams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;
            return DataCell(
              Container(
                width: 60,
                color: team.teamColor.withOpacity(0.6),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}°',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    ];

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 10.0, // Reducir espacio entre columnas
          headingRowHeight: 40.0, // Reducir altura de las filas de encabezado
          dataRowHeight: 40.0, // Reducir altura de las filas de datos
          columns: [
            const DataColumn(label: Text('')),
            ...sortedTeams.map((team) => DataColumn(
                  label: Container(
                    width: 60,
                    color: team.teamColor.withOpacity(0.8),
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        team.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )),
          ],
          rows: dataRows,
        ),
      ),
    );
  }
}
