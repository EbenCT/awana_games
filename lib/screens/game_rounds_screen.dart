// lib/screens/game_rounds_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/game_provider.dart';
import '../widgets/common/score_card.dart';
import '../widgets/score_counter/number_grid.dart';

class GameRoundsScreen extends StatefulWidget {
  const GameRoundsScreen({Key? key}) : super(key: key);

  @override
  State<GameRoundsScreen> createState() => _GameRoundsScreenState();
}

class _GameRoundsScreenState extends State<GameRoundsScreen> with SingleTickerProviderStateMixin {
  late List<Team> teams;
  List<int> selectedNumbers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    teams = [
      Team(id: 1, name: 'Rojo', teamColor: Colors.red),
      Team(id: 2, name: 'Amarillo', teamColor: Colors.amber),
      Team(id: 3, name: 'Verde', teamColor: Colors.green),
      Team(id: 4, name: 'Azul', teamColor: Colors.blue),
    ];
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
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
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego por Rondas'),
        elevation: 0,
      ),
      body: isLandscape
          ? _buildLandscapeLayout(gameProvider)
          : _buildPortraitLayout(gameProvider),
    );
  }
  
  Widget _buildPortraitLayout(GameProvider gameProvider) {
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
                            setState(() {
                              final updatedPoints = team.roundPoints + change;
                              if (updatedPoints >= 0) {
                                teams[teams.indexOf(team)] = team.copyWith(
                                  roundPoints: updatedPoints,
                                );
                              }
                            });
                          },
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
  
  Widget _buildLandscapeLayout(GameProvider gameProvider) {
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
                      setState(() {
                        final updatedPoints = team.roundPoints + change;
                        if (updatedPoints >= 0) {
                          teams[teams.indexOf(team)] = team.copyWith(
                            roundPoints: updatedPoints,
                          );
                        }
                      });
                    },
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
                // Implementar lógica para finalizar ronda
                Navigator.pop(context);
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
}