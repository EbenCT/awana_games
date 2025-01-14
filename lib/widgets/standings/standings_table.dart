// lib/widgets/standings/standings_table.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../models/team.dart';

class StandingsTable extends StatelessWidget {
  final List<Game> games;
  final List<Team> teams;

  const StandingsTable({
    Key? key,
    required this.games,
    required this.teams,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
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
                child: _buildTable(sortedTeams, positions),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTable(List<Team> sortedTeams, Map<int, int> positions) {
    return DataTable(
      columnSpacing: 10.0,
      headingRowHeight: 40.0,
      dataRowHeight: 40.0,
      columns: [
        const DataColumn(label: Text('')),
        ...sortedTeams.map((team) => _buildTeamColumn(team)),
      ],
      rows: [
        ..._buildGameRows(sortedTeams),
        _buildTotalRow(sortedTeams),
        _buildPositionRow(sortedTeams, positions),
      ],
    );
  }

  DataColumn _buildTeamColumn(Team team) {
    return DataColumn(
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
    );
  }

  List<DataRow> _buildGameRows(List<Team> sortedTeams) {
    return List.generate(games.length, (i) {
      return DataRow(
        cells: [
          DataCell(SizedBox(
            width: 60,
            child: Text(
              games[i].name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          ...sortedTeams.map((team) => _buildScoreCell(team, i)),
        ],
      );
    });
  }

  DataCell _buildScoreCell(Team team, int gameIndex) {
    return DataCell(
      Container(
        width: 60,
        color: team.teamColor.withOpacity(0.2),
        alignment: Alignment.center,
        child: Text(
          team.gameScores.length > gameIndex
              ? (team.gameScores[gameIndex]?.toString() ?? '-')
              : '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  DataRow _buildTotalRow(List<Team> sortedTeams) {
    return DataRow(
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
    );
  }

  DataRow _buildPositionRow(List<Team> sortedTeams, Map<int, int> positions) {
    return DataRow(
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
    );
  }

  Map<int, int> _calculatePositions(List<Team> sortedTeams) {
    Map<int, int> positions = {};
    int currentPosition = 1;
    int teamsWithSameScore = 1;

    for (int i = 0; i < sortedTeams.length; i++) {
      if (i > 0 && sortedTeams[i].totalScore == sortedTeams[i - 1].totalScore) {
        positions[sortedTeams[i].id] = positions[sortedTeams[i - 1].id]!;
        teamsWithSameScore++;
      } else {
        positions[sortedTeams[i].id] = currentPosition;
        currentPosition = i + teamsWithSameScore + 1;
        teamsWithSameScore = 1;
      }
    }
    return positions;
  }
}
