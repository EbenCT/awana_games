// lib/screens/game_config_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/common/primary_button.dart';

class GameConfigScreen extends StatefulWidget {
  const GameConfigScreen({Key? key}) : super(key: key);

  @override
  State<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends State<GameConfigScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<TextEditingController> _gameNameControllers = [];
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
  }
  
  void _initControllers() {
    _gameNameControllers.clear();
    for (int i = 0; i < _gameCount; i++) {
      _gameNameControllers.add(TextEditingController(text: 'Juego ${i + 1}'));
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
        _gameCount--;
      });
    }
  }
  
  void _saveConfiguration() {
    if (_formKey.currentState!.validate()) {
      final gameNames = _gameNameControllers.map((controller) => controller.text.trim()).toList();
      
      // Guardar la configuración en el provider
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.configureGames(gameNames);
      
      // Navegar a la pantalla de puntuación
      Navigator.pushReplacementNamed(context, '/score');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            controller: _gameNameControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Nombre del Juego ${index + 1}',
                              prefixIcon: Icon(
                                Icons.sports_esports,
                                // Adaptar el color al tema
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              // Adaptar el color de relleno según el tema
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              // Mejorar color de texto del label para modo oscuro
                              labelStyle: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                              // Mejorar color de texto para modo oscuro
                              hintStyle: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            // Ajustar color del texto ingresado para mejor visibilidad
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa un nombre para este juego';
                              }
                              return null;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  text: 'Guardar y Continuar',
                  icon: Icons.save,
                  onPressed: _saveConfiguration,
                  fullWidth: true,
                  variant: ButtonVariant.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}