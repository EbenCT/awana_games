// lib/services/notification_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationTest {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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
    
    // Verificar permisos
    await _requestPermissions();
  }
  
  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      try {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Permisos de notificación Android concedidos: $granted');
      } catch (e) {
        debugPrint('Error al solicitar permisos de Android: $e');
      }
    }
  }
  
  // Mostrar una notificación inmediatamente
  static Future<void> showTestNotification() async {
    // Detalles de Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel', 
      'Prueba de Notificaciones',
      channelDescription: 'Canal para probar notificaciones',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6A1B9A),
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    
    // Detalles de iOS
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
    
    // Mostrar notificación inmediata
    await _notificationsPlugin.show(
      100, // ID diferente al de las notificaciones programadas
      '¡Prueba de notificación!',
      'Esta es una notificación de prueba. Si la estás viendo, las notificaciones están funcionando correctamente.',
      notificationDetails,
      payload: 'test_notification',
    );
    
    debugPrint('Notificación de prueba enviada');
  }
  
  // Verificar notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
  
  // Verificar y mostrar notificaciones pendientes en consola
  static Future<void> checkPendingNotifications() async {
    final pending = await getPendingNotifications();
    debugPrint('Notificaciones pendientes: ${pending.length}');
    
    for (var notification in pending) {
      debugPrint('ID: ${notification.id}');
      debugPrint('Título: ${notification.title}');
      debugPrint('Cuerpo: ${notification.body}');
      debugPrint('------------------');
    }
  }
}