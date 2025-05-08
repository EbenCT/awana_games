// lib/screens/edit_score_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../providers/teams_provider.dart';
import '../providers/game_provider.dart';

class EditScoreScreen extends StatefulWidget {
  final int gameIndex;
  
  const EditScoreScreen({
    Key? key,
    required this.gameIndex,
  }) : super(key: key);

  @override
  State<EditScoreScreen> createState() => _EditScoreScreenState();
}

class _EditScoreScreenState extends State<EditScoreScreen> {
  late Map<int, TextEditingController> _scoreControllers;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    
    _scoreControllers = {};
    for (var team in teamsProvider.teams) {
      final score = team.gameScores.length > widget.gameIndex 
          ? team.gameScores[widget.gameIndex] ?? 0 
          : 0;
      _scoreControllers[team.id] = TextEditingController(text: score.toString());
    }
  }
  
  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.games[widget.gameIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Puntuaciones: ${game.name}'),
        actions: [
          TextButton.icon(
            onPressed: _saveScores,
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: teamsProvider.teams.length,
        itemBuilder: (context, index) {
          final team = teamsProvider.teams[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Círculo con color del equipo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: team.teamColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nombre del equipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          game.type == GameType.rounds 
                              ? 'Puntos por rondas: ${team.getRoundPoints(widget.gameIndex)}' 
                              : 'Puntuación normal',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Campo para editar la puntuación
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _scoreControllers[team.id],
                      decoration: InputDecoration(
                        labelText: 'Puntos',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? team.teamColor.withOpacity(0.9) : team.teamColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _saveScores() {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    
    // Validar y convertir las puntuaciones
    bool hasError = false;
    Map<int, int> newScores = {};
    
    for (var entry in _scoreControllers.entries) {
      final teamId = entry.key;
      final controller = entry.value;
      
      try {
        final score = int.parse(controller.text);
        if (score < 0) throw FormatException('Puntuación negativa');
        newScores[teamId] = score;
      } catch (e) {
        hasError = true;
        controller.text = '0'; // Reset a 0 en caso de error
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa un número válido para todos los equipos'),
            backgroundColor: Colors.red,
          ),
        );
        
        break;
      }
    }
    
    if (!hasError) {
      // Guardar las nuevas puntuaciones
      for (var entry in newScores.entries) {
        teamsProvider.editScore(entry.key, widget.gameIndex, entry.value);
      }
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Puntuaciones actualizadas correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Volver a la pantalla anterior
      Navigator.pop(context);
    }
  }
}