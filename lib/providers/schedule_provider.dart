// lib/providers/schedule_provider.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

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
      
      // NUEVO: Verificar y renovar notificaciones si es necesario
      if (_notificationsEnabled) {
        await _checkAndRenewNotificationsIfNeeded();
      }
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
      
      // Si las notificaciones están habilitadas, reprogramar
      if (_notificationsEnabled) {
        await _scheduleNotifications();
      }
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
      
      if (enabled) {
        // Programar notificaciones
        await _scheduleNotifications();
      } else {
        // Cancelar notificaciones
        await NotificationService.cancelWeeklyNotifications();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cambiar estado de notificaciones: $e');
    }
  }

  // NUEVO: Método privado para programar notificaciones
  Future<void> _scheduleNotifications() async {
    try {
      final dayOfWeekIndex = getDayOfWeekIndex();
      await NotificationService.scheduleWeeklyNotification(
        dayOfWeek: dayOfWeekIndex,
        hour: _time.hour,
        minute: _time.minute,
      );
      debugPrint('Notificaciones semanales reprogramadas desde ScheduleProvider');
    } catch (e) {
      debugPrint('Error al programar notificaciones desde ScheduleProvider: $e');
    }
  }

  // NUEVO: Verificar y renovar notificaciones si es necesario
  Future<void> _checkAndRenewNotificationsIfNeeded() async {
    try {
      await NotificationService.checkAndRenewNotifications(
        getDayOfWeekIndex(),
        _time.hour,
        _time.minute,
      );
    } catch (e) {
      debugPrint('Error al verificar notificaciones: $e');
    }
  }

  // NUEVO: Método público para forzar renovación de notificaciones
  Future<void> forceRenewNotifications() async {
    if (_notificationsEnabled) {
      try {
        await _scheduleNotifications();
        debugPrint('Notificaciones renovadas manualmente');
      } catch (e) {
        debugPrint('Error al renovar notificaciones manualmente: $e');
      }
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

  // NUEVO: Obtener información de estado de notificaciones
  Future<Map<String, dynamic>> getNotificationStatus() async {
    try {
      final pendingNotifications = await NotificationService.getPendingNotifications();
      final weeklyNotifications = pendingNotifications.where(
        (notification) => notification.id >= 1000 && notification.id < 1008
      ).toList();
      
      return {
        'total_pending': pendingNotifications.length,
        'weekly_notifications': weeklyNotifications.length,
        'notifications_enabled': _notificationsEnabled,
        'next_renewal_needed': weeklyNotifications.length < 3,
      };
    } catch (e) {
      debugPrint('Error al obtener estado de notificaciones: $e');
      return {
        'total_pending': 0,
        'weekly_notifications': 0,
        'notifications_enabled': _notificationsEnabled,
        'next_renewal_needed': true,
      };
    }
  }
}