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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return isSmallScreen 
            ? _buildCompactVerticalTable(sortedTeams, positions)
            : _buildFullVerticalTable(sortedTeams, positions);
        },
      ),
    );
  }

  // Nueva tabla vertical compacta
  Widget _buildCompactVerticalTable(List<Team> sortedTeams, Map<int, int> positions) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 100, child: Text('Juego')),
                ...teams.map((team) => Expanded(
                  child: Center(
                    child: Row(
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
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            team.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          ...List.generate(games.length, (gameIndex) {
            final game = games[gameIndex];
            return Container(
              decoration: BoxDecoration(
                color: gameIndex.isEven ? Colors.grey[50] : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        game.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...teams.map((team) => Expanded(
                      child: Center(
                        child: Text(
                          team.gameScores.length > gameIndex
                            ? (team.gameScores[gameIndex]?.toString() ?? '-')
                            : '-',
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            );
          }),
          // Añadimos la fila de posiciones justo antes del TOTAL
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12, 
                horizontal: 8,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'POSICIÓN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...teams.map((team) => Expanded(
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: team.teamColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: team.teamColor),
                        ),
                        child: Center(
                          child: Text(
                            '${positions[team.id]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: team.teamColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          // Fila para el total acumulado
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...teams.map((team) => Expanded(
                    child: Center(
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: team.totalScore),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: team.teamColor,
                            ),
                          );
                        },
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nueva tabla vertical completa
  Widget _buildFullVerticalTable(List<Team> sortedTeams, Map<int, int> positions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tabla de Posiciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          DataTable(
            columnSpacing: 16.0,
            headingRowHeight: 48.0,
            dataRowHeight: 56.0,
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            border: TableBorder.all(
              color: Colors.grey[300]!,
              width: 1,
              borderRadius: BorderRadius.circular(8),
            ),
            columns: [
              const DataColumn(
                label: Text(
                  'Juego',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...teams.map((team) => DataColumn(
                label: Row(
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
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        team.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            rows: [
              ...List.generate(games.length, (gameIndex) {
                final game = games[gameIndex];
                return DataRow(
                  cells: [
                    DataCell(Text(game.name)),
                    ...teams.map((team) => DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: team.gameScores.length > gameIndex &&
                                team.gameScores[gameIndex] != null
                                ? team.teamColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            team.gameScores.length > gameIndex
                                ? (team.gameScores[gameIndex]?.toString() ?? '-')
                                : '-',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: team.gameScores.length > gameIndex &&
                                  team.gameScores[gameIndex] != null
                                  ? team.teamColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                );
              }),
              // Fila de posiciones
              DataRow(
                color: MaterialStateProperty.all(Colors.grey[50]),
                cells: [
                  const DataCell(Text(
                    'POSICIÓN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  ...teams.map((team) => DataCell(
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: team.teamColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${positions[team.id]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: team.teamColor,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              // Fila total
              DataRow(
                color: MaterialStateProperty.all(Colors.grey[100]),
                cells: [
                  const DataCell(Text(
                    'TOTAL',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  ...teams.map((team) => DataCell(
                    Center(
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: team.totalScore),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: team.teamColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$value',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: team.teamColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método auxiliar para calcular las posiciones finales
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