// lib/screens/standings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  int currentGameIndex = 0;

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final games = gameProvider.games;
    final teams = teamsProvider.teams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Posiciones'),
      ),
      body: Column(
        children: [
          _buildGameNavigator(games),
          Expanded(
            child: _buildStandingsTable(games, teams),
          ),
        ],
      ),
    );
  }

  Widget _buildGameNavigator(List<Game> games) {
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
                games.isNotEmpty ? games[currentGameIndex].name : 'Ningún Juego',
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

  Widget _buildStandingsTable(List<Game> games, List<Team> teams) {
    // Ordenar equipos por puntaje total
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // Calcular posiciones considerando empates
    final positions = _calculatePositions(sortedTeams);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                  columnSpacing: 10.0,
                  headingRowHeight: 40.0,
                  dataRowHeight: 40.0,
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
                  rows: [
                    // Filas para cada juego
                    for (int i = 0; i < games.length; i++)
                      DataRow(
                        cells: [
                          DataCell(SizedBox(
                            width: 60,
                            child: Text(
                              'Juego ${i + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )),
                          ...sortedTeams.map((team) => DataCell(
                            Container(
                              width: 60,
                              color: team.teamColor.withOpacity(0.2),
                              alignment: Alignment.center,
                              child: Text(
                                team.gameScores.length > i
                                    ? (team.gameScores[i]?.toString() ?? '-')
                                    : '-',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                        ],
                      ),
                    // Fila de totales
                    DataRow(
                      cells: [
                        const DataCell(Text(
                          'TOTAL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
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
                    // Fila de posiciones
                    DataRow(
                      cells: [
                        const DataCell(Text(
                          'Puesto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        ...sortedTeams.map((team) => DataCell(
                          Container(
                            width: 60,
                            color: team.teamColor.withOpacity(0.6),
                            alignment: Alignment.center,
                            child: Text(
                              '${positions[team.id]}°',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<int, int> _calculatePositions(List<Team> sortedTeams) {
    Map<int, int> positions = {};
    int currentPosition = 1;
    int teamsWithSameScore = 1;
    
    for (int i = 0; i < sortedTeams.length; i++) {
      if (i > 0 && sortedTeams[i].totalScore == sortedTeams[i - 1].totalScore) {
        // Si el puntaje es igual al anterior, mantener la misma posición
        positions[sortedTeams[i].id] = positions[sortedTeams[i - 1].id]!;
        teamsWithSameScore++;
      } else {
        // Si el puntaje es diferente, asignar la siguiente posición
        positions[sortedTeams[i].id] = currentPosition;
        currentPosition = i + teamsWithSameScore + 1;
        teamsWithSameScore = 1;
      }
    }
    
    return positions;
  }
}