// lib/services/notification_service.dart (con gestión de permisos)
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  static const int _gameNotificationBaseId = 1000;
  static bool _initialized = false;

  // Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Inicializar zonas horarias
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/La_Paz'));
    
    debugPrint('🔔 Zona horaria configurada: ${tz.local.name}');
    debugPrint('🔔 Offset actual: ${DateTime.now().timeZoneOffset.inHours}h ${DateTime.now().timeZoneOffset.inMinutes % 60}m');
    
    // Configuración para Android con canal más específico
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
    
    // Verificar permisos inmediatamente después de inicializar
    await _checkAndRequestPermissions();
    
    debugPrint('✅ Servicio de notificaciones inicializado');
  }
  
  // NUEVO: Verificar y solicitar permisos
  static Future<bool?> _checkAndRequestPermissions() async {
    if (!_initialized) await initialize();
    
    try {
      // En Android 13+, necesitamos solicitar permisos explícitamente
      if (Platform.isAndroid) {
        // Verificar si ya tenemos permisos
        final bool? granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
            
        debugPrint('🔔 Permisos de notificación habilitados: $granted');
        
        if (granted != true) {
          // Solicitar permisos
          debugPrint('📱 Solicitando permisos de notificación...');
          final bool? result = await _notificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
              
          debugPrint('📱 Resultado de solicitud de permisos: $result');
          return result ?? false;
        }
        
        return granted;
      } else if (Platform.isIOS) {
        // Para iOS, verificar permisos
        final bool? result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        debugPrint('🍎 Permisos iOS solicitados: $result');
        return result ?? false;
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Error al verificar/solicitar permisos: $e');
      return false;
    }
  }
  
  // NUEVO: Método público para verificar permisos
  static Future<bool> checkPermissions() async {
    if (!_initialized) await initialize();
    
    try {
      if (Platform.isAndroid) {
        final bool? granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        return granted ?? false;
      } else if (Platform.isIOS) {
        // Para iOS es más complejo verificar, así que asumimos que sí si llegamos aquí
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error al verificar permisos: $e');
      return false;
    }
  }
  
  // NUEVO: Método público para solicitar permisos
  static Future<bool?> requestPermissions() async {
    return await _checkAndRequestPermissions();
  }
  
  // Programar notificaciones semanales (con verificación de permisos)
  static Future<bool> scheduleWeeklyNotification({
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();
    
    // VERIFICAR PERMISOS ANTES DE PROGRAMAR
    final hasPermissions = await checkPermissions();
    if (!hasPermissions) {
      debugPrint('❌ No hay permisos para notificaciones. Solicitando...');
      final granted = await requestPermissions();
      if (!granted!) {
        debugPrint('❌ Permisos denegados. No se pueden programar notificaciones.');
        return false;
      }
    }
    
    try {
      // Cancelar todas las notificaciones semanales existentes
      await cancelWeeklyNotifications();
      
      // Nombres de los días para debug
      final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final dayName = days[dayOfWeek - 1];
      
      debugPrint('=== PROGRAMANDO NOTIFICACIONES SEMANALES ===');
      debugPrint('Día: $dayName ($dayOfWeek), Hora: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      
      // Programar múltiples notificaciones individuales
      final List<tz.TZDateTime> scheduledDates = [];
      tz.TZDateTime nextDate = _nextInstanceOfDay(dayOfWeek, hour, minute);
      
      // Programar para las próximas 8 semanas
      for (int weekNumber = 0; weekNumber < 8; weekNumber++) {
        final notificationId = _gameNotificationBaseId + weekNumber;
        final currentDate = nextDate.add(Duration(days: weekNumber * 7));
        scheduledDates.add(currentDate);
        
        debugPrint('Semana ${weekNumber + 1}: ${currentDate.toString()} (ID: $notificationId)');
        
        // Detalles específicos para cada notificación
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'weekly_game_channel',
          'Tiempo de Juegos Semanal',
          channelDescription: 'Recordatorios semanales para el tiempo de juegos',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          color: Color(0xFF6A1B9A),
          icon: '@mipmap/ic_launcher',
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
        
        // Textos para la notificación
        final title = '¡Es tiempo de jugar! 🎮';
        final body = 'Es momento de tu tiempo de juegos.\n'
                    'Abre la app para comenzar una nueva sesión.\n'
                    'Programado cada $dayName a las ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        
        // Programar cada notificación individual
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          currentDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'weekly_game_reminder_week_${weekNumber + 1}',
        );
      }
      
      // Verificar que se programaron correctamente
      final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
      final weeklyNotifications = pendingNotifications.where(
        (notification) => notification.id >= _gameNotificationBaseId && 
                         notification.id < _gameNotificationBaseId + 8
      ).toList();
      
      debugPrint('=== VERIFICACIÓN ===');
      debugPrint('Notificaciones semanales programadas: ${weeklyNotifications.length}/8');
      
      for (final notification in weeklyNotifications) {
        debugPrint('ID ${notification.id}: ${notification.title}');
      }
      
      if (weeklyNotifications.length == 8) {
        debugPrint('✅ Todas las notificaciones semanales programadas exitosamente');
        
        // Programar renovación automática para dentro de 6 semanas
        await _scheduleRenewalNotification(dayOfWeek, hour, minute);
        return true;
      } else {
        debugPrint('⚠️ Solo se programaron ${weeklyNotifications.length} de 8 notificaciones');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ Error al programar notificaciones semanales: $e');
      return false;
    }
  }
  
  // Programar una notificación para pruebas (con verificación de permisos)
  static Future<bool> scheduleNotificationForTesting() async {
    if (!_initialized) await initialize();
    
    // VERIFICAR PERMISOS
    final hasPermissions = await checkPermissions();
    if (!hasPermissions) {
      debugPrint('❌ No hay permisos para notificaciones de prueba');
      return false;
    }
    
    try {
      // Cancelar notificaciones existentes
      await _notificationsPlugin.cancel(999);
      
      // Crear una fecha 1 minuto en el futuro
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = now.add(const Duration(minutes: 1));
      
      debugPrint('Programando notificación de prueba para: ${scheduledTime.toString()}');
      
      // Detalles de Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Pruebas',
        channelDescription: 'Canal para pruebas de notificaciones',
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
        999, // ID específico para pruebas
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
      
      if (pendingNotifications.any((notification) => notification.id == 999)) {
        debugPrint('✅ Notificación de prueba programada exitosamente');
        return true;
      } else {
        debugPrint('⚠️ La notificación de prueba NO fue programada correctamente');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al programar notificación de prueba: $e');
      return false;
    }
  }
  
  // Mostrar una notificación inmediata (con verificación de permisos)
  static Future<bool> showImmediateNotification() async {
    if (!_initialized) await initialize();
    
    // VERIFICAR PERMISOS
    final hasPermissions = await checkPermissions();
    if (!hasPermissions) {
      debugPrint('❌ No hay permisos para notificación inmediata. Solicitando...');
      final granted = await requestPermissions();
      if (!granted!) {
        debugPrint('❌ Permisos denegados para notificación inmediata');
        return false;
      }
    }
    
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'immediate_channel',
        'Notificaciones Inmediatas',
        channelDescription: 'Canal para notificaciones inmediatas',
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
        999999, // ID único para inmediata
        'Notificación Inmediata ✓',
        'Esta es una notificación de prueba.\n'
        'Hora local: $nowFormatted\n'
        'Zona horaria: $tzName',
        notificationDetails,
      );
      
      debugPrint('✅ Notificación inmediata enviada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al mostrar notificación inmediata: $e');
      return false;
    }
  }
  
  // Programar una notificación para renovar las notificaciones semanales
  static Future<void> _scheduleRenewalNotification(int dayOfWeek, int hour, int minute) async {
    try {
      // Programar renovación en 6 semanas (antes de que se agoten)
      final renewalDate = _nextInstanceOfDay(dayOfWeek, hour, minute).add(const Duration(days: 42)); // 6 semanas
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'renewal_channel',
        'Renovación de Recordatorios',
        channelDescription: 'Notificación para renovar recordatorios semanales',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: false,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notificationsPlugin.zonedSchedule(
        _gameNotificationBaseId + 50, // ID único para renovación
        'Recordatorios programados',
        'Tus recordatorios semanales han sido renovados automáticamente.',
        renewalDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'renewal_notification',
      );
      
      debugPrint('Renovación programada para: $renewalDate');
    } catch (e) {
      debugPrint('Error al programar renovación: $e');
    }
  }
  
  // Calcular próxima ocurrencia de un día (sin cambios)
  static tz.TZDateTime _nextInstanceOfDay(int day, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
      0,
    );
    
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    int daysToAdd = 0;
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      daysToAdd++;
      
      if (daysToAdd > 7) {
        debugPrint('⚠️ Error: bucle infinito detectado en cálculo de fecha');
        break;
      }
    }
    
    return scheduledDate;
  }
  
  // Cancelar todas las notificaciones semanales
  static Future<void> cancelWeeklyNotifications() async {
    try {
      // Cancelar las 8 notificaciones semanales
      for (int i = 0; i < 8; i++) {
        await _notificationsPlugin.cancel(_gameNotificationBaseId + i);
      }
      
      // Cancelar la notificación de renovación
      await _notificationsPlugin.cancel(_gameNotificationBaseId + 50);
      
      debugPrint('Notificaciones semanales canceladas');
    } catch (e) {
      debugPrint('Error al cancelar notificaciones semanales: $e');
    }
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
  
  // Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notificationsPlugin.pendingNotificationRequests();
  }
  
  // Método para verificar y renovar notificaciones si es necesario
  static Future<void> checkAndRenewNotifications(int dayOfWeek, int hour, int minute) async {
    try {
      final pendingNotifications = await getPendingNotifications();
      final weeklyNotifications = pendingNotifications.where(
        (notification) => notification.id >= _gameNotificationBaseId && 
                         notification.id < _gameNotificationBaseId + 8
      ).toList();
      
      debugPrint('Notificaciones semanales activas: ${weeklyNotifications.length}');
      
      // Si hay menos de 3 notificaciones semanales, renovar
      if (weeklyNotifications.length < 3) {
        debugPrint('Pocas notificaciones semanales restantes, renovando...');
        await scheduleWeeklyNotification(
          dayOfWeek: dayOfWeek,
          hour: hour,
          minute: minute,
        );
      }
    } catch (e) {
      debugPrint('Error al verificar notificaciones: $e');
    }
  }
}