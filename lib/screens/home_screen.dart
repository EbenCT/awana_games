// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/configuration_menu.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/teams_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          ConfigurationMenu(),
          SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Colored quadrants background with animation
                  Positioned(
                    top: 0,
                    left: 0,
                    right: size.width / 2,
                    bottom: size.height / 2,
                    child: Transform.translate(
                      offset: Offset(
                        -100 * (1 - _animationController.value), 
                        -100 * (1 - _animationController.value)
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(50 * _animationController.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: size.width / 2,
                    right: 0,
                    bottom: size.height / 2,
                    child: Transform.translate(
                      offset: Offset(
                        100 * (1 - _animationController.value), 
                        -100 * (1 - _animationController.value)
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50 * _animationController.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height / 2,
                    left: 0,
                    right: size.width / 2,
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(
                        -100 * (1 - _animationController.value), 
                        100 * (1 - _animationController.value)
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50 * _animationController.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height / 2,
                    left: size.width / 2,
                    right: 0,
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(
                        100 * (1 - _animationController.value), 
                        100 * (1 - _animationController.value)
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow[600],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50 * _animationController.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Logo and content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo container
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: isLandscape ? size.height * 0.4 : size.width * 0.5,
                        height: isLandscape ? size.height * 0.4 : size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
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
                                style: GoogleFonts.fredoka(
                                  fontSize: isLandscape ? size.height * 0.08 : size.width * 0.08,
                                  fontWeight: FontWeight.bold,
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
                                style: GoogleFonts.fredoka(
                                  fontSize: isLandscape ? size.height * 0.08 : size.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Animated game icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        final icons = [
                          Icons.sports_soccer,
                          Icons.emoji_events,
                          Icons.extension,
                          Icons.timer,
                        ];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + index * 200),
                          curve: Curves.bounceOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: [
                              Colors.red[400], 
                              Colors.yellow[600], 
                              Colors.green[400], 
                              Colors.blue[400]
                            ][index],
                            radius: 28,
                            child: Icon(
                              icons[index],
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom button with animation - Usando AnimatedOpacity en lugar de TweenAnimationBuilder
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - _animationController.value)),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Verificar si hay juegos en curso
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      if (gameProvider.games.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PrimaryButton(
                            text: 'Continuar Juego',
                            icon: Icons.play_circle,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/score');
                            },
                            backgroundColor: Colors.green,
                            fullWidth: true,
                            variant: ButtonVariant.success,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Botón de nuevo juego
                  PrimaryButton(
                    text: 'Nuevo Juego',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      // Reiniciar equipos y juegos
                      teamsProvider.resetScores();
                      gameProvider.resetGames();
                      // Crear el primer juego
                      gameProvider.addGame();
                      // Navegar a la tabla de posiciones
                      Navigator.of(context).pushNamed('/score');
                    },
                    backgroundColor: Colors.purple,
                    fullWidth: true,
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}