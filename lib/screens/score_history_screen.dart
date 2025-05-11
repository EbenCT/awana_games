// lib/screens/score_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Añadir esta dependencia al pubspec.yaml
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';

class ScoreHistoryScreen extends StatelessWidget {
  const ScoreHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final history = teamsProvider.scoreChangeHistory;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Ordenar el historial de más reciente a más antiguo
    history.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Cambios'),
      ),
      body: history.isEmpty
        ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay cambios registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los cambios en las puntuaciones se mostrarán aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final timestamp = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                final formattedDate = dateFormat.format(timestamp);
                
                final gameIndex = item['gameIndex'];
                final gameName = gameIndex < gameProvider.games.length
                    ? gameProvider.games[gameIndex].name
                    : 'Juego desconocido';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Cambio en "${gameName}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Equipo: ${item['teamName']}'),
                        Text('Puntuación anterior: ${item['oldScore'] ?? 0}'),
                        Text('Nueva puntuación: ${item['newScore']}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.edit,
                      color: isDarkMode ? Colors.yellow[700] : Colors.amber,
                    ),
                  ),
                );
              },
            ),
    );
  }
}