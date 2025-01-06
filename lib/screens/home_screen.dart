import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/common/primary_button.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/teams_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Colored quadrants background
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(color: Colors.blue[600]),
                    ),
                    Expanded(
                      child: Container(color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(color: Colors.yellow[600]),
                    ),
                    Expanded(
                      child: Container(color: Colors.green[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Center white circle with app name
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                alignment: Alignment.center,
                  children: [
                  // Borde negro del texto
                    Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial Rounded MT Bold',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 8
                        ..strokeCap = StrokeCap.round
                        ..strokeJoin = StrokeJoin.round
                        ..color = Colors.black,
                    ),
                    ),
                  // Texto amarillo principal
                    Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial Rounded MT Bold',
                      color: Colors.yellow[600],
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom button
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: PrimaryButton(
              text: 'Iniciar Juego',
              onPressed: () {
                // Reiniciar equipos y juegos
                teamsProvider.resetScores();
                gameProvider.resetGames();

                // Crear el primer juego
                gameProvider.addGame();

                // Navegar a la tabla de posiciones
                Navigator.pushNamed(context, '/score');
              },
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}