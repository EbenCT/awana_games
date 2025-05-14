// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  static const int _gameNotificationId = 1;
  static bool _initialized = false;

  // Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Inicializar zonas horarias
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/La_Paz'));
    
    debugPrint('Zona horaria configurada: ${tz.local.name}');
    debugPrint('Offset actual: ${DateTime.now().timeZoneOffset.inHours}h ${DateTime.now().timeZoneOffset.inMinutes % 60}m');
    
    // Configuración para Android
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración para iOS
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    // Configuración general
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Inicializar el plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notificación tocada: ${details.payload}');
      },
    );
    
    _initialized = true;
    
    // Verificar notificaciones pendientes
    final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('Notificaciones pendientes: ${pendingNotifications.length}');
  }
  
  // Programar una notificación para pruebas
  static Future<void> scheduleNotificationForTesting() async {
    if (!_initialized) await initialize();
    
    try {
      // Cancelar notificaciones existentes
      await _notificationsPlugin.cancel(_gameNotificationId);
      
      // Crear una fecha 1 minuto en el futuro
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = now.add(const Duration(minutes: 1));
      
      debugPrint('Programando notificación para: ${scheduledTime.toString()}');
      
      // Detalles de Android (simplificados)
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'game_time_channel',
        'Tiempo de Juegos',
        channelDescription: 'Notificaciones para recordar el tiempo de juegos',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      
      // Detalles de iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Configuración general
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Textos de la notificación
      final title = '¡Tiempo de Juego! (Prueba)';
      final body = 'Notificación de prueba programada para 1 minuto después.\n'
                  'Hora programada: ${DateFormat('HH:mm:ss').format(
                    DateTime(
                      scheduledTime.year,
                      scheduledTime.month,
                      scheduledTime.day,
                      scheduledTime.hour,
                      scheduledTime.minute,
                      scheduledTime.second,
                    )
                  )}';
      
      // Programar la notificación
      await _notificationsPlugin.zonedSchedule(
        _gameNotificationId,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      // Verificar si se programó exitosamente
      final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
      
      if (pendingNotifications.any((notification) => notification.id == _gameNotificationId)) {
        debugPrint('Notificación programada exitosamente');
      } else {
        debugPrint('⚠️ La notificación NO fue programada correctamente');
      }
    } catch (e) {
      debugPrint('Error al programar notificación: $e');
    }
  }
  
  // Programar una notificación semanal
  static Future<void> scheduleWeeklyNotification({
    required int dayOfWeek, // 1 = lunes, 7 = domingo
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();
    
    try {
      // Cancelar notificaciones existentes
      await _notificationsPlugin.cancel(_gameNotificationId);
      
      // Calcular próxima ocurrencia
      final scheduledDate = _nextInstanceOfDay(dayOfWeek, hour, minute);
      
      // Nombres de los días
      final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final dayName = days[dayOfWeek - 1];
      
      debugPrint('Programando notificación semanal para $dayName a las ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      debugPrint('Primera ocurrencia: $scheduledDate');
      
      // Detalles de Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'game_time_channel',
        'Tiempo de Juegos',
        channelDescription: 'Notificaciones para recordar el tiempo de juegos',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      
      // Detalles de iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Configuración general
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Textos para la notificación
      final title = '¡Es tiempo de jugar!';
      final body = 'Ingresa a la app para comenzar tu tiempo de juegos.\n'
                  'Programado cada $dayName a las ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      
      // Programar la notificación semanal
      await _notificationsPlugin.zonedSchedule(
        _gameNotificationId,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      
      // Verificar si se programó correctamente
      final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
      
      if (pendingNotifications.any((notification) => notification.id == _gameNotificationId)) {
        debugPrint('Notificación semanal programada exitosamente');
      } else {
        debugPrint('⚠️ La notificación semanal NO fue programada correctamente');
      }
    } catch (e) {
      debugPrint('Error al programar notificación semanal: $e');
    }
  }
  
  // Mostrar una notificación inmediata
  static Future<void> showImmediateNotification() async {
    if (!_initialized) await initialize();
    
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Prueba de Notificaciones',
        channelDescription: 'Canal para pruebas',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Información para el texto
      final now = DateTime.now();
      final tzName = tz.local.name;
      final nowFormatted = DateFormat('HH:mm:ss').format(now);
      
      // Mostrar la notificación
      await _notificationsPlugin.show(
        99, // ID diferente
        'Notificación Inmediata',
        'Esta es una notificación de prueba.\n'
        'Hora local: $nowFormatted\n'
        'Zona horaria: $tzName',
        notificationDetails,
      );
      
      debugPrint('Notificación inmediata enviada exitosamente');
    } catch (e) {
      debugPrint('Error al mostrar notificación inmediata: $e');
    }
  }
  
  // Calcular próxima ocurrencia de un día
  static tz.TZDateTime _nextInstanceOfDay(int day, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // Si ya pasó la hora hoy, programamos para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Ajustar al día de la semana correcto
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  // Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Todas las notificaciones canceladas');
    } catch (e) {
      debugPrint('Error al cancelar notificaciones: $e');
    }
  }
  
  // Cancelar notificación de juego
  static Future<void> cancelGameNotification() async {
    try {
      await _notificationsPlugin.cancel(_gameNotificationId);
      debugPrint('Notificación de juego cancelada');
    } catch (e) {
      debugPrint('Error al cancelar notificación de juego: $e');
    }
  }
  
  // Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}