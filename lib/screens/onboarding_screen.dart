// lib/screens/onboarding_screen.dart (corregido)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Importar para usar cos y sin en animaciones
import '../services/notification_service.dart';
import '../widgets/common/primary_button.dart';
import '../providers/schedule_provider.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  final List<String> _days = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 
    'Viernes', 'Sábado', 'Domingo'
  ];
  String _selectedDay = 'Sábado';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 15, minute: 30);
  bool _isLoading = false;
  
  // Controladores para las animaciones de los elementos
  late Animation<double> _backgroundAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Configurar las animaciones con diferentes curvas y duraciones
    _backgroundAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    
    _titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
    );
    
    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.bounceOut),
    );
    
    // Iniciar las animaciones
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.white,
              hourMinuteTextColor: Theme.of(context).colorScheme.primary,
              dayPeriodTextColor: Theme.of(context).colorScheme.primary,
              dayPeriodBorderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Guardar en provider
      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
      scheduleProvider.setSchedule(_selectedDay, _selectedTime);
      
      // Guardar en SharedPreferences que el onboarding se completó
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      
      // Programar la notificación
      final dayOfWeek = _days.indexOf(_selectedDay) + 1; // 1 = lunes, 7 = domingo
      await NotificationService.scheduleWeeklyNotification(
        dayOfWeek: dayOfWeek,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      debugPrint('Error al guardar la programación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la programación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mediaQuerySize = MediaQuery.of(context).size;
    
    // Formatear la hora seleccionada
    final formattedTime = DateFormat('h:mm a').format(
      DateTime(2022, 1, 1, _selectedTime.hour, _selectedTime.minute)
    );
    
    // Colores para el fondo animado
    final List<List<Color>> backgroundColors = [
      [Colors.purple[700]!, Colors.purple[500]!],
      [Colors.blue[800]!, Colors.blue[500]!],
      [Colors.amber[800]!, Colors.amber[500]!],
      [Colors.red[700]!, Colors.red[500]!],
    ];
    
    // Iconos para ilustrar la pantalla
    final List<IconData> activityIcons = [
      Icons.sports_soccer,
      Icons.emoji_events,
      Icons.celebration,
      Icons.timer,
      Icons.people,
      Icons.star,
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con animación
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, _) {
              return Stack(
                children: [
                  // Capa base del fondo
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple[900]!,
                          Colors.indigo[800]!,
                        ],
                      ),
                    ),
                  ),
                  
                  // Formas animadas en el fondo
                  ...List.generate(4, (index) {
                    final progress = _backgroundAnimation.value;
                    final delay = index * 0.2; // Retraso escalonado
                    final adjustedProgress = (progress - delay).clamp(0.0, 1.0);
                    
                    // Posiciones iniciales fuera de la pantalla
                    final startPositions = [
                      Offset(-mediaQuerySize.width * 0.5, -mediaQuerySize.height * 0.2),
                      Offset(mediaQuerySize.width * 1.5, -mediaQuerySize.height * 0.3),
                      Offset(-mediaQuerySize.width * 0.3, mediaQuerySize.height * 1.2),
                      Offset(mediaQuerySize.width * 1.2, mediaQuerySize.height * 1.3),
                    ];
                    
                    // Posiciones finales
                    final endPositions = [
                      Offset(mediaQuerySize.width * 0.1, mediaQuerySize.height * 0.1),
                      Offset(mediaQuerySize.width * 0.6, mediaQuerySize.height * 0.2),
                      Offset(mediaQuerySize.width * 0.2, mediaQuerySize.height * 0.7),
                      Offset(mediaQuerySize.width * 0.7, mediaQuerySize.height * 0.5),
                    ];
                    
                    // Calcular posición actual con interpolación
                    final currentPosition = Offset(
                      startPositions[index].dx + (endPositions[index].dx - startPositions[index].dx) * adjustedProgress,
                      startPositions[index].dy + (endPositions[index].dy - startPositions[index].dy) * adjustedProgress,
                    );
                    
                    // Tamaño de las formas
                    final shapeSize = 250.0 * adjustedProgress;
                    
                    return Positioned(
                      left: currentPosition.dx - (shapeSize / 2),
                      top: currentPosition.dy - (shapeSize / 2),
                      child: Opacity(
                        opacity: 0.6 * adjustedProgress,
                        child: Container(
                          width: shapeSize,
                          height: shapeSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: backgroundColors[index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(shapeSize / 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2 * adjustedProgress),
                                blurRadius: 20 * adjustedProgress,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Añadir estrellas brillantes animadas
                  ...List.generate(20, (index) {
                    final progress = _backgroundAnimation.value;
                    final random = index / 20; // Para distribuir las estrellas
                    final delay = random * 0.5; // Retraso variado
                    final adjustedProgress = (progress - delay).clamp(0.0, 1.0);
                    
                    // Posición aleatoria
                    final posX = index % 5 * (mediaQuerySize.width / 5) + (random * 60);
                    final posY = (index ~/ 5) * (mediaQuerySize.height / 5) + (random * 80);
                    
                    return Positioned(
                      left: posX,
                      top: posY,
                      child: Opacity(
                        opacity: adjustedProgress,
                        child: Container(
                          width: 8 + (random * 8),
                          height: 8 + (random * 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 10 * adjustedProgress,
                                spreadRadius: 2 * adjustedProgress,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: mediaQuerySize.height * 0.05),
                    
                    // Título animado
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _titleAnimation.value,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          // Título principal con efecto de texto
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Sombra del texto
                              Text(
                                '¡Bienvenido!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 8
                                    ..strokeCap = StrokeCap.round
                                    ..strokeJoin = StrokeJoin.round
                                    ..color = Colors.black,
                                ),
                              ),
                              // Texto principal
                              Text(
                                '¡Bienvenido!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Círculo de iconos animados
                          SizedBox(
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: List.generate(activityIcons.length, (index) {
                                final angle = (index / activityIcons.length) * 2 * pi; // pi de dart:math
                                final radius = 40.0; // Radio del círculo
                                
                                return AnimatedBuilder(
                                  animation: _titleAnimation,
                                  builder: (context, child) {
                                    // Posición en círculo con animación
                                    final progress = _titleAnimation.value.clamp(0.0, 1.0);
                                    final delayedProgress = ((progress * 1.5) - (index * 0.1)).clamp(0.0, 1.0);
                                    
                                    return Transform.translate(
                                      offset: Offset(
                                        cos(angle) * radius * delayedProgress,
                                        sin(angle) * radius * delayedProgress,
                                      ),
                                      child: Opacity(
                                        opacity: delayedProgress,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: [
                                      Colors.red[400],
                                      Colors.yellow[600],
                                      Colors.green[400],
                                      Colors.blue[400],
                                      Colors.purple[400],
                                      Colors.amber[600],
                                    ][index % 6],
                                    radius: 18,
                                    child: Icon(
                                      activityIcons[index],
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Pregunta principal con animación
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                          ),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            '¿Cuándo realizas el tiempo de juegos?',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Configura el día y la hora para recibir notificaciones y no olvidar tu tiempo de juegos',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Tarjeta de selección con animación
                    AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            50 * (1 - _cardAnimation.value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.grey[850]!.withOpacity(0.9) 
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selector de día
                              Text(
                                'Día de la semana',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode 
                                      ? Colors.white 
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? Colors.grey[900] 
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedDay,
                                  dropdownColor: isDarkMode 
                                      ? Colors.grey[850] 
                                      : Colors.white,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.calendar_today,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    filled: false,
                                  ),
                                  style: TextStyle(
                                    color: isDarkMode 
                                        ? Colors.white 
                                        : Colors.black87,
                                    fontSize: 16,
                                  ),
                                  items: _days.map((day) {
                                    return DropdownMenuItem(
                                      value: day,
                                      child: Text(day),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedDay = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Selector de hora
                              Text(
                                'Hora',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode 
                                      ? Colors.white 
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _showTimePicker,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode 
                                        ? Colors.grey[900] 
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode 
                                              ? Colors.white 
                                              : Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: isDarkMode 
                                            ? Colors.white 
                                            : Colors.grey[700],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Información adicional
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Recibirás notificaciones semanales para recordarte tu tiempo de juegos',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Botón de continuar con animación
                    AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonAnimation.value,
                          child: child,
                        );
                      },
                      child: _isLoading
                          ? Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : PrimaryButton(
                              text: 'Comenzar',
                              icon: Icons.play_arrow,
                              onPressed: _saveSchedule,
                              fullWidth: true,
                              variant: ButtonVariant.success,
                            ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}