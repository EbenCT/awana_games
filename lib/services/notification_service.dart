// lib/services/notification_service.dart (con zona horaria automática)
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // Nuevo paquete

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  static const int _gameNotificationId = 1;

  // Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    // Inicializar zonas horarias
    tz_data.initializeTimeZones();
    
    // Obtener la zona horaria del dispositivo automáticamente
    await _configureLocalTimeZone();
    
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
        // Este callback se dispara cuando el usuario toca la notificación
        debugPrint('Notificación tocada: ${details.payload}');
      },
    );
    
    // Verificar y solicitar permisos en iOS
    await _requestPermissions();
  }
  
  // Configurar zona horaria local basada en el dispositivo
  static Future<void> _configureLocalTimeZone() async {
    try {
      // Obtener la zona horaria del dispositivo
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      
      // Establecer la zona horaria como la zona horaria local
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      debugPrint('Zona horaria configurada automáticamente: $timeZoneName');
    } catch (e) {
      // En caso de error, usar una zona horaria por defecto
      debugPrint('Error al configurar zona horaria: $e');
      debugPrint('Usando zona horaria por defecto: America/La_Paz');
      
      // Establecer Bolivia como zona horaria de respaldo
      tz.setLocalLocation(tz.getLocation('America/La_Paz'));
    }
  }
  
  // Solicitar permisos explícitamente (principalmente para iOS)
  static Future<void> _requestPermissions() async {
    // Para Android 13+ (API 33+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      try {
        // Usar el método correcto según la versión disponible
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Permisos de notificación Android concedidos: $granted');
      } catch (e) {
        // Si el método no está disponible, podría ser una versión anterior de Android
        // o una versión anterior del plugin
        debugPrint('Error al solicitar permisos de Android: $e');
      }
    }
        
    // Para iOS
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
            
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
  
  // Programar una notificación para una fecha y hora específicas (para pruebas)
  static Future<void> scheduleNotificationForTesting(tz.TZDateTime scheduledDate) async {
    // Cancelar notificaciones existentes con el mismo ID
    await _notificationsPlugin.cancel(_gameNotificationId);
    
    // Configurar detalles de Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'game_time_channel',
      'Tiempo de Juegos',
      channelDescription: 'Notificaciones para recordar el tiempo de juegos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF6A1B9A), // Color principal de la app (violeta)
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    
    // Configurar detalles de iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    
    // Configuración general
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Programar la notificación
    await _notificationsPlugin.zonedSchedule(
      _gameNotificationId,
      '¡Es tiempo de jugar!',
      'Ingresa a la app para comenzar tu tiempo de juegos (Prueba)',
      scheduledDate,
      notificationDetails,
      // Nuevos parámetros requeridos para la versión 18.0.1
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'game_time_test',
    );
    
    // Mostrar la zona horaria actual
    final currentTz = tz.local;
    
    debugPrint('Zona horaria actual: ${currentTz.name}');
    debugPrint('Hora local: ${DateTime.now()}');
    debugPrint('Notificación de prueba programada para: $scheduledDate');
  }
  
  // Programar una notificación semanal que se repite en un día y hora específicos
  static Future<void> scheduleWeeklyNotification({
    required int dayOfWeek, // 1 = lunes, 7 = domingo
    required int hour,      // 0-23
    required int minute,    // 0-59
  }) async {
    // Cancelar notificaciones existentes con el mismo ID
    await _notificationsPlugin.cancel(_gameNotificationId);
    
    // Configurar detalles de Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'game_time_channel',
      'Tiempo de Juegos',
      channelDescription: 'Notificaciones para recordar el tiempo de juegos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF6A1B9A), // Color principal de la app (violeta)
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    
    // Configurar detalles de iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    
    // Configuración general
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Calcular la fecha y hora para la próxima ocurrencia
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = _nextInstanceOfDay(dayOfWeek, hour, minute);
    
    // Programar la notificación
    await _notificationsPlugin.zonedSchedule(
      _gameNotificationId,
      '¡Es tiempo de jugar!',
      'Ingresa a la app para comenzar tu tiempo de juegos',
      scheduledDate,
      notificationDetails,
      // Nuevos parámetros requeridos para la versión 18.0.1
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'game_time',
    );
    
    // Mostrar información para depuración
    final currentTz = tz.local;
    debugPrint('Zona horaria actual: ${currentTz.name}');
    debugPrint('Hora local: ${DateTime.now()}');
    debugPrint('Notificación programada para: $scheduledDate');
  }
  
  // Calcular la fecha y hora de la próxima ocurrencia
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
    
    // Si el día actual es mayor que el día de la semana deseado,
    // avanzamos a la próxima semana
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Si la fecha ya pasó hoy, programamos para la próxima semana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }
  
  // Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
  
  // Cancelar una notificación específica
  static Future<void> cancelGameNotification() async {
    await _notificationsPlugin.cancel(_gameNotificationId);
  }
  
  // Verificar si hay notificaciones activas
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}