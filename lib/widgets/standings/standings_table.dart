// lib/widgets/standings/standings_table.dart (mejorado para tema oscuro)
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../models/team.dart';

class StandingsTable extends StatefulWidget {
  final List<Game> games;
  final List<Team> teams;
  
  const StandingsTable({
    Key? key,
    required this.games,
    required this.teams,
  }) : super(key: key);
  
  @override
  State<StandingsTable> createState() => StandingsTableState();
}

class StandingsTableState extends State<StandingsTable> {
  // Expose the key that will be used to capture the table as an image
  final GlobalKey tableKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    final sortedTeams = List<Team>.from(widget.teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final positions = _calculatePositions(sortedTeams);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return RepaintBoundary(
      key: tableKey,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return isSmallScreen
                ? _buildCompactVerticalTable(sortedTeams, positions, isDarkMode)
                : _buildFullVerticalTable(sortedTeams, positions, isDarkMode);
          },
        ),
      ),
    );
  }
  
  // Nueva tabla vertical compacta
  Widget _buildCompactVerticalTable(List<Team> sortedTeams, Map<int, int> positions, bool isDarkMode) {
    // Colores adaptados para modo oscuro
    final headerColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    final evenRowColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final oddRowColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700] : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    //final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100, 
                  child: Text(
                    'Juego',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  )
                ),
                ...widget.teams.map((team) => Expanded(
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
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          ...List.generate(widget.games.length, (gameIndex) {
            final game = widget.games[gameIndex];
            return Container(
              decoration: BoxDecoration(
                color: gameIndex.isEven ? evenRowColor : oddRowColor,
                border: Border(
                  bottom: BorderSide(
                    color: borderColor!,
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
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    ...widget.teams.map((team) => Expanded(
                      child: Center(
                        child: Text(
                          team.gameScores.length > gameIndex
                              ? (team.gameScores[gameIndex]?.toString() ?? '-')
                              : '-',
                          style: TextStyle(
                            color: isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor,
                          ),
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
              color: evenRowColor,
              border: Border(
                bottom: BorderSide(
                  color: borderColor!,
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
                      'POSICIÓN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  ...widget.teams.map((team) => Expanded(
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
                              color: isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor,
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
              color: headerColor,
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
                  SizedBox(
                    width: 100,
                    child: Text(
                      'TOTAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  ...widget.teams.map((team) => Expanded(
                    child: Center(
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: team.totalScore),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor,
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
  Widget _buildFullVerticalTable(List<Team> sortedTeams, Map<int, int> positions, bool isDarkMode) {
    final headerColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    final evenRowColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final textColor = isDarkMode ? Colors.white : Colors.grey[800];
    final borderColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    
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
                color: textColor,
              ),
            ),
          ),
          DataTable(
            columnSpacing: 16.0,
            headingRowHeight: 48.0,
            dataRowHeight: 56.0,
            headingRowColor: MaterialStateProperty.all(headerColor),
            border: TableBorder.all(
              color: borderColor!,
              width: 1,
              borderRadius: BorderRadius.circular(8),
            ),
            columns: [
              DataColumn(
                label: Text(
                  'Juego',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              ...widget.teams.map((team) => DataColumn(
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            rows: [
              ...List.generate(widget.games.length, (gameIndex) {
                final game = widget.games[gameIndex];
                return DataRow(
                  color: gameIndex.isEven 
                      ? MaterialStateProperty.all(evenRowColor)
                      : null,
                  cells: [
                    DataCell(Text(
                      game.name,
                      style: TextStyle(color: textColor),
                    )),
                    ...widget.teams.map((team) => DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: team.gameScores.length > gameIndex &&
                                    team.gameScores[gameIndex] != null
                                ? team.teamColor.withOpacity(isDarkMode ? 0.2 : 0.1)
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
                                  ? (isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor)
                                  : (isDarkMode ? Colors.grey[400] : Colors.grey),
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
                color: MaterialStateProperty.all(evenRowColor),
                cells: [
                  DataCell(Text(
                    'POSICIÓN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  )),
                  ...widget.teams.map((team) => DataCell(
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: team.teamColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${positions[team.id]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              // Fila total
              DataRow(
                color: MaterialStateProperty.all(headerColor),
                cells: [
                  DataCell(Text(
                    'TOTAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  )),
                  ...widget.teams.map((team) => DataCell(
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
                              color: team.teamColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$value',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor,
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