// lib/providers/schedule_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleProvider with ChangeNotifier {
  String _day = 'Sábado';  // Día por defecto
  TimeOfDay _time = const TimeOfDay(hour: 15, minute: 30);  // Hora por defecto (3:30 PM)
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  // Getters
  String get day => _day;
  TimeOfDay get time => _time;
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  // Inicializar y cargar preferencias
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar día
      final savedDay = prefs.getString('schedule_day');
      if (savedDay != null) {
        _day = savedDay;
      }
      
      // Cargar hora (guardada como minutos desde medianoche)
      final savedTimeMinutes = prefs.getInt('schedule_time_minutes');
      if (savedTimeMinutes != null) {
        final hour = savedTimeMinutes ~/ 60;
        final minute = savedTimeMinutes % 60;
        _time = TimeOfDay(hour: hour, minute: minute);
      }
      
      // Cargar estado de notificaciones
      final notificationsState = prefs.getBool('notifications_enabled');
      if (notificationsState != null) {
        _notificationsEnabled = notificationsState;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al inicializar ScheduleProvider: $e');
    }
  }

  // Establecer día y hora
  Future<void> setSchedule(String day, TimeOfDay time) async {
    _day = day;
    _time = time;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedule_day', day);
      
      // Guardar la hora como minutos desde medianoche para facilitar la persistencia
      final timeInMinutes = time.hour * 60 + time.minute;
      await prefs.setInt('schedule_time_minutes', timeInMinutes);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al guardar programación: $e');
    }
  }

  // Habilitar/deshabilitar notificaciones
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cambiar estado de notificaciones: $e');
    }
  }

  // Método para obtener el índice del día (1 = lunes, 7 = domingo)
  int getDayOfWeekIndex() {
    final days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 
      'Viernes', 'Sábado', 'Domingo'
    ];
    
    return days.indexOf(_day) + 1;
  }

  // Obtener una representación legible de la programación
  String getFormattedSchedule() {
    // Formatear la hora (con AM/PM)
    String period = _time.hour < 12 ? 'AM' : 'PM';
    int displayHour = _time.hour % 12;
    if (displayHour == 0) displayHour = 12;
    
    String minutes = _time.minute.toString().padLeft(2, '0');
    
    return '$_day a las $displayHour:$minutes $period';
  }
}