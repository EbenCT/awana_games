// lib/screens/game_rounds_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/game_provider.dart';
import '../providers/teams_provider.dart'; // Añadido para acceder al provider de equipos
import '../widgets/common/score_card.dart';
import '../widgets/score_counter/number_grid.dart';

class GameRoundsScreen extends StatefulWidget {
  const GameRoundsScreen({Key? key}) : super(key: key);

  @override
  State<GameRoundsScreen> createState() => _GameRoundsScreenState();
}

class _GameRoundsScreenState extends State<GameRoundsScreen> with SingleTickerProviderStateMixin {
  List<int> selectedNumbers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int currentGameIndex = 0; // Para saber en qué juego estamos
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    // Obtenemos el índice del juego actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final games = gameProvider.games;
      for (int i = 0; i < games.length; i++) {
        if (games[i].isCurrent) {
          setState(() {
            currentGameIndex = i;
          });
          break;
        }
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNumberSelected(int number) {
    if (!selectedNumbers.contains(number)) {
      setState(() {
        selectedNumbers.add(number);
      });
      
      // Animate when selecting a number
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final teamsProvider = Provider.of<TeamsProvider>(context);
    final teams = teamsProvider.teams;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego por Rondas'),
        elevation: 0,
      ),
      body: isLandscape
          ? _buildLandscapeLayout(gameProvider, teams, teamsProvider)
          : _buildPortraitLayout(gameProvider, teams, teamsProvider),
    );
  }
  
  Widget _buildPortraitLayout(GameProvider gameProvider, List<Team> teams, TeamsProvider teamsProvider) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: teams.map((team) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ScoreCard(
                          team: team,
                          showRoundPoints: true,
                          onPointsChanged: (change) {
                            _updateTeamRoundPoints(team, change, teamsProvider);
                          },
                          // Obtener los puntos de ronda del provider
                          roundPoints: teamsProvider.getTeamRoundPoints(team.id, currentGameIndex),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: NumberGrid(
                      selectedNumbers: selectedNumbers,
                      onNumberSelected: _onNumberSelected,
                      maxNumbers: gameProvider.maxGridNumbers,
                      onAddNumber: () {
                        gameProvider.incrementMaxNumbers();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }
  
  Widget _buildLandscapeLayout(GameProvider gameProvider, List<Team> teams, TeamsProvider teamsProvider) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Teams section
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: teams.map((team) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ScoreCard(
                    team: team,
                    showRoundPoints: true,
                    onPointsChanged: (change) {
                      _updateTeamRoundPoints(team, change, teamsProvider);
                    },
                    // Obtener los puntos de ronda del provider
                    roundPoints: teamsProvider.getTeamRoundPoints(team.id, currentGameIndex),
                  ),
                )).toList(),
              ),
            ),
          ),
          
          // Number grid and bottom bar
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: NumberGrid(
                      selectedNumbers: selectedNumbers,
                      onNumberSelected: _onNumberSelected,
                      maxNumbers: gameProvider.maxGridNumbers,
                      onAddNumber: () {
                        gameProvider.incrementMaxNumbers();
                      },
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _updateTeamRoundPoints(Team team, int change, TeamsProvider teamsProvider) {
    // Obtener los puntos actuales
    int currentPoints = teamsProvider.getTeamRoundPoints(team.id, currentGameIndex);
    
    // Calcular los nuevos puntos
    int newPoints = currentPoints + change;
    
    // Asegurar que los puntos no sean negativos
    if (newPoints >= 0) {
      // Actualizar los puntos de ronda para el equipo y juego específico
      teamsProvider.updateTeamRoundPoints(team.id, currentGameIndex, newPoints);
    }
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Números seleccionados: ${selectedNumbers.length}/${Provider.of<GameProvider>(context).maxGridNumbers}',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _finalizarRonda();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Finalizar Ronda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _finalizarRonda() {
    // Obtenemos los providers
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // Ordenamos los equipos por sus puntos de ronda
    List<Team> sortedTeams = List.from(teamsProvider.teams);
    sortedTeams.sort((a, b) => 
      teamsProvider.getTeamRoundPoints(b.id, currentGameIndex)
        .compareTo(teamsProvider.getTeamRoundPoints(a.id, currentGameIndex))
    );
    
    // Asignar puntuaciones según la posición (ejemplo: 100, 75, 50, 25 puntos)
    Map<int, int> scoreForPosition = {0: 100, 1: 75, 2: 50, 3: 25};
    
    for (int i = 0; i < sortedTeams.length; i++) {
      Team team = sortedTeams[i];
      int score = scoreForPosition[i] ?? 0;
      
      // Actualizar la puntuación del juego para este equipo
      teamsProvider.updateScore(team.id, currentGameIndex, score);
    }
    
    // Marcar el juego como completado si es necesario
    gameProvider.markGameAsCompleted(currentGameIndex);
    
    // Volver a la pantalla anterior
    Navigator.pop(context);
  }
}