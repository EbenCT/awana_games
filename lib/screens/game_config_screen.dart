// lib/screens/game_config_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../providers/game_provider.dart';

class GameConfigScreen extends StatefulWidget {
  const GameConfigScreen({Key? key}) : super(key: key);

  @override
  State<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends State<GameConfigScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<TextEditingController> _gameNameControllers = [];
  final List<bool> _enableTimer = [];
  final List<int> _timerDurations = [];
  int _gameCount = 5; // Por defecto comenzamos con 5 juegos
  final _formKey = GlobalKey<FormState>();
  
@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();
  
  // Inicializar controladores
  _initControllers();
  
  // Inicializar timers (por defecto desactivados)
  _enableTimer.clear();
  _timerDurations.clear();
  for (int i = 0; i < _gameCount; i++) {
    _enableTimer.add(false);
    _timerDurations.add(300); // 5 minutos por defecto
  }
}
  
void _initControllers() {
  _gameNameControllers.clear();
  
  // Si ya hay juegos configurados, cargar sus valores
  final gameProvider = Provider.of<GameProvider>(context, listen: false);
  final existingGames = gameProvider.games;
  
  for (int i = 0; i < _gameCount; i++) {
    if (i < existingGames.length) {
      // Usar nombre y configuración de temporizador existentes
      _gameNameControllers.add(TextEditingController(text: existingGames[i].name));
      _enableTimer.add(existingGames[i].hasTimer);
      _timerDurations.add(existingGames[i].timerDuration);
    } else {
      // Usar valores por defecto para nuevos juegos
      _gameNameControllers.add(TextEditingController(text: 'Juego ${i + 1}'));
      _enableTimer.add(false);
      _timerDurations.add(300);
    }
  }
}
  
  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _gameNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _increaseGameCount() {
  if (_gameCount < 15) { // Limitamos a un máximo de 15 juegos
    setState(() {
      _gameCount++;
      _gameNameControllers.add(TextEditingController(text: 'Juego $_gameCount'));
      _enableTimer.add(false); // Por defecto, sin temporizador
      _timerDurations.add(300); // 5 minutos por defecto
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Máximo 15 juegos permitidos'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

void _decreaseGameCount() {
  if (_gameCount > 1) { // Mínimo debe haber 1 juego
    setState(() {
      _gameNameControllers.last.dispose();
      _gameNameControllers.removeLast();
      _enableTimer.removeLast();
      _timerDurations.removeLast();
      _gameCount--;
    });
  }
}
  
  void _saveConfiguration() {
    if (_formKey.currentState!.validate()) {
      final gameNames = _gameNameControllers.map((controller) => controller.text.trim()).toList();
      
    // Crear una lista de juegos con su configuración completa
      final games = <Game>[];
      for (int i = 0; i < gameNames.length; i++) {
        games.add(Game(
          id: i + 1,
          name: gameNames[i],
          type: GameType.normal, // Por defecto todos son juegos normales
          isCompleted: false,
          isCurrent: i == 0, // El primer juego es el actual
          hasTimer: _enableTimer[i],
          timerDuration: _timerDurations[i],
        ));
      }

      // Guardar la configuración en el provider
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.configureGames(gameNames);
      
    // Actualizar la configuración de temporizador para cada juego
      for (int i = 0; i < games.length; i++) {
        gameProvider.updateGameTimer(i, _enableTimer[i], _timerDurations[i]);
      }

      // Navegar a la pantalla de puntuación
      Navigator.pushReplacementNamed(context, '/score');
    }
  }

@override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDarkMode ? Colors.white : Colors.black87;
  
  return Scaffold(
    appBar: AppBar(
      title: const Text('Configurar Juegos'),
      elevation: 0,
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cantidad de Juegos: $_gameCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _decreaseGameCount,
                        icon: const Icon(Icons.remove_circle),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Disminuir cantidad de juegos',
                      ),
                      IconButton(
                        onPressed: _increaseGameCount,
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Aumentar cantidad de juegos',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: FadeTransition(
                opacity: _animationController,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _gameCount,
                  itemBuilder: (context, index) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index / (_gameCount * 2),
                          (index + 1) / _gameCount,
                          curve: Curves.easeOutCubic,
                        ),
                      )),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre del juego
                              TextFormField(
                                controller: _gameNameControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Nombre del Juego ${index + 1}',
                                  prefixIcon: Icon(
                                    Icons.sports_esports,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                  labelStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                                style: TextStyle(
                                  color: textColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor ingresa un nombre para este juego';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Sección de temporizador (más compacta)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: _enableTimer[index] 
                                            ? Theme.of(context).colorScheme.primary 
                                            : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Temporizador',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: _enableTimer[index] 
                                              ? Theme.of(context).colorScheme.primary 
                                              : textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // Si está habilitado, mostrar opciones de duración
                                      if (_enableTimer[index])
                                        DropdownButton<int>(
                                          value: _timerDurations[index],
                                          underline: Container(), // Quitar la línea inferior
                                          isDense: true,
                                          items: [
                                            DropdownMenuItem(
                                              value: 60,
                                              child: const Text('1 min'),
                                            ),
                                            DropdownMenuItem(
                                              value: 120,
                                              child: const Text('2 min'),
                                            ),
                                            DropdownMenuItem(
                                              value: 180,
                                              child: const Text('3 min'),
                                            ),
                                            DropdownMenuItem(
                                              value: 300,
                                              child: const Text('5 min'),
                                            ),
                                            DropdownMenuItem(
                                              value: 600,
                                              child: const Text('10 min'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _timerDurations[index] = value;
                                              });
                                            }
                                          },
                                        ),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: _enableTimer[index],
                                        onChanged: (value) {
                                          setState(() {
                                            _enableTimer[index] = value;
                                          });
                                        },
                                        activeColor: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _saveConfiguration,
                icon: const Icon(Icons.save),
                label: const Text('Guardar y Continuar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}