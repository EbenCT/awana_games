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
  // Obtener los resultados del juego actual
  final currentGame = games[currentGameIndex];
  final List<Map<String, dynamic>> gameResults = _calculateGameResults(currentGame);

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Navegación y título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentGameIndex > 0
                      ? () => setState(() => currentGameIndex--)
                      : null,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Resultados por juego',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showEditGameNameDialog(context, currentGame),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentGame.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentGameIndex < games.length - 1
                      ? () => setState(() => currentGameIndex++)
                      : null,
                ),
              ],
            ),
            // Podio de resultados
            if (gameResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: gameResults.map((result) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: result['teamColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: _getMedalColor(result['position']),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${result['position']}°',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getMedalColor(result['position']),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          result['teamName'],
                          style: TextStyle(
                            color: result['teamColor'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (result['points'] != null)
                          Text(
                            '${result['points']} pts',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
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
                              '${games[i].name}',
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
  Color _getMedalColor(int position) {
  switch (position) {
    case 1:
      return Colors.amber;
    case 2:
      return Colors.grey[400]!;
    case 3:
      return Colors.orange[700]!;
    default:
      return Colors.grey[600]!;
  }
}

List<Map<String, dynamic>> _calculateGameResults(Game game) {
  final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
  final teams = teamsProvider.teams;
  
  // Crear una lista de resultados para este juego específico
  final results = teams.map((team) {
    final gameScore = team.gameScores.length > currentGameIndex
        ? team.gameScores[currentGameIndex]
        : null;
    return {
      'teamId': team.id,
      'teamName': team.name,
      'teamColor': team.teamColor,
      'score': gameScore,
      'points': game.type == GameType.rounds ? team.roundPoints : null,
    };
  }).toList();
  
  // Ordenar por puntaje
  results.sort((a, b) => ((b['score'] ?? 0) as int).compareTo((a['score'] ?? 0) as int));
  
  // Asignar posiciones considerando empates
  int currentPosition = 1;
  int sameScoreCount = 1;
  
  for (int i = 0; i < results.length; i++) {
    if (i > 0 && results[i]['score'] == results[i - 1]['score']) {
      results[i]['position'] = results[i - 1]['position'];
      sameScoreCount++;
    } else {
      results[i]['position'] = currentPosition;
      currentPosition = i + sameScoreCount + 1;
      sameScoreCount = 1;
    }
  }
  
  return results;
}

Future<void> _showEditGameNameDialog(BuildContext context, Game game) async {
  final TextEditingController controller = TextEditingController(text: game.name);
  final gameProvider = Provider.of<GameProvider>(context, listen: false);

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar nombre del juego'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Nombre del juego',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty) {
              gameProvider.updateGameName(currentGameIndex, newName);
            }
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
}