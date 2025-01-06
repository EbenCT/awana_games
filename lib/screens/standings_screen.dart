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
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    final List<DataRow> dataRows = [
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
          rows: dataRows,
        ),
      ),
    );
  }
}
