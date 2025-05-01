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
              ? _buildCompactTable(sortedTeams, positions)
              : _buildFullTable(sortedTeams, positions);
        },
      ),
    );
  }
  
  Widget _buildCompactTable(List<Team> sortedTeams, Map<int, int> positions) {
    return Column(
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
              const SizedBox(width: 40, child: Text('Pos')),
              const SizedBox(width: 8),
              const Expanded(child: Text('Equipo')),
              ...List.generate(games.length, (index) => 
                Flexible(
                  flex: 1,
                  child: Center(
                    child: Text('J${index + 1}', 
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
              ),
              const SizedBox(width: 16),
              const SizedBox(width: 60, child: Center(child: Text('Total'))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedTeams.length,
            itemBuilder: (context, index) {
              final team = sortedTeams[index];
              final position = positions[team.id]!;
              
              return Container(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.grey[50] : Colors.white,
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
                        width: 40,
                        child: _buildPositionWidget(position),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: team.teamColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                team.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(
                        games.length,
                        (gameIndex) => Flexible(
                          flex: 1,
                          child: Center(
                            child: Text(
                              team.gameScores.length > gameIndex
                                  ? (team.gameScores[gameIndex]?.toString() ?? '-')
                                  : '-',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: team.totalScore),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Text(
                                '$value',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: team.teamColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildFullTable(List<Team> sortedTeams, Map<int, int> positions) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
                    'Pos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Equipo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(
                  games.length,
                  (index) => DataColumn(
                    label: Tooltip(
                      message: games[index].name,
                      child: Text(
                        'Juego ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'TOTAL',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: sortedTeams.map((team) {
                final position = positions[team.id]!;
                
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return position == 1
                          ? Colors.amber.withOpacity(0.05)
                          : position == 2
                              ? Colors.grey.withOpacity(0.05)
                              : position == 3
                                  ? Colors.orange[100]!.withOpacity(0.05)
                                  : Colors.transparent;
                    },
                  ),
                  cells: [
                    DataCell(_buildPositionWidget(position)),
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
                          Text(
                            team.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(
                      games.length,
                      (gameIndex) => DataCell(
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: team.gameScores.length > gameIndex && team.gameScores[gameIndex] != null
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
                                color: team.gameScores.length > gameIndex && team.gameScores[gameIndex] != null
                                    ? team.teamColor
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
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
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionWidget(int position) {
    IconData? icon;
    Color? color;
    
    switch (position) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey[400];
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.orange[700];
        break;
      default:
        break;
    }
    
    return position <= 3
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text('$position°'),
            ],
          )
        : Text('$position°');
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