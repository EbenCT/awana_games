// lib/screens/onboarding_screen.dart (con solicitud de permisos)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/permission_dialog.dart';
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
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Configurar animaciones más simples
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
      // PASO 1: Solicitar permisos de notificación ANTES de programar
      debugPrint('🔔 Solicitando permisos de notificación...');
      final hasPermissions = await PermissionDialog.ensureNotificationPermissions(
        context, 
        showDialog: true
      );
      
      if (!hasPermissions!) {
        // Si no se otorgaron permisos, mostrar diálogo informativo
        if (mounted) {
          await PermissionDialog.showPermissionDeniedDialog(context);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      
      // PASO 2: Guardar en provider
      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
      await scheduleProvider.setSchedule(_selectedDay, _selectedTime);
      
      // PASO 3: Guardar en SharedPreferences que el onboarding se completó
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      
      // PASO 4: Programar las notificaciones (solo si tenemos permisos)
      if (hasPermissions) {
        debugPrint('🔔 Programando notificaciones semanales...');
        final dayOfWeek = _days.indexOf(_selectedDay) + 1; // 1 = lunes, 7 = domingo
        final success = await NotificationService.scheduleWeeklyNotification(
          dayOfWeek: dayOfWeek,
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
        );
        
        if (success) {
          debugPrint('✅ Notificaciones programadas exitosamente');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recordatorios configurados para ${scheduleProvider.day} a las ${_selectedTime.format(context)}',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          debugPrint('⚠️ Error al programar notificaciones');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Configuración guardada, pero revisa los permisos de notificación'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        debugPrint('⚠️ Sin permisos, solo guardando configuración');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Configuración guardada. Puedes activar notificaciones después en Configuración.'),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
      
      // PASO 5: Navegar a la pantalla principal
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
      
    } catch (e) {
      debugPrint('❌ Error al guardar la programación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al guardar la configuración: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Formatear la hora seleccionada
    final formattedTime = DateFormat('h:mm a').format(
      DateTime(2022, 1, 1, _selectedTime.hour, _selectedTime.minute)
    );
    
    return Scaffold(
      body: Stack(
        children: [
          // FONDO SIMPLIFICADO
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple[800]!,
                  Colors.indigo[700]!,
                ],
              ),
            ),
          ),
          
          // Superposición de elementos decorativos simples que se animan con FadeIn
          FadeTransition(
            opacity: _fadeInAnimation,
            child: Stack(
              children: [
                // Círculo grande en la esquina superior derecha
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.purple[400]!.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Círculo mediano en la esquina inferior izquierda
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.indigo[300]!.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Forma redondeada en la parte inferior derecha
                Positioned(
                  bottom: 20,
                  right: -70,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.amber[700]!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido principal con animación de slide
          SafeArea(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Título con animación
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Column(
                          children: [
                            // Título principal
                            Text(
                              '¡Bienvenido!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Fila de iconos de juego
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildIconCircle(Icons.sports_soccer, Colors.red[400]!),
                                const SizedBox(width: 12),
                                _buildIconCircle(Icons.emoji_events, Colors.amber[600]!),
                                const SizedBox(width: 12),
                                _buildIconCircle(Icons.celebration, Colors.green[400]!),
                                const SizedBox(width: 12),
                                _buildIconCircle(Icons.timer, Colors.blue[400]!),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Pregunta principal
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Text(
                          '¿Cuándo realizas el tiempo de juegos?',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Text(
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
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Tarjeta de selección
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.grey[850]!.withOpacity(0.9) 
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
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
                                
                                // NUEVA SECCIÓN: Información sobre permisos
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.notifications_active,
                                            color: Colors.blue[700],
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Te pediremos permisos para notificaciones',
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white.withOpacity(0.9)
                                                    : Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Solo enviaremos recordatorios según tu programación. Puedes cambiar esto en cualquier momento.',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.black54,
                                          fontSize: 12,
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
                      
                      // Botón de continuar
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: _isLoading
                            ? Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        'Configurando...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
          ),
        ],
      ),
    );
  }
  
  // Helper para crear círculos de iconos
  Widget _buildIconCircle(IconData icon, Color color) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 24,
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}