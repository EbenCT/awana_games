// lib/services/notification_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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
  }
  
  // Mostrar una notificación inmediatamente
  static Future<void> showTestNotification() async {
    try {
      // Detalles de Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel', 
        'Prueba de Notificaciones',
        channelDescription: 'Canal para probar notificaciones',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        playSound: true,
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
      
      // Información de diagnóstico
      final now = DateTime.now();
      final tzInfo = tz.local.name;
      
      // Texto para la notificación
      final body = 'Esta es una notificación de prueba.\n'
                   'Hora local: ${now.hour}:${now.minute}\n'
                   'Zona horaria: $tzInfo';
      
      // Mostrar notificación
      await _notificationsPlugin.show(
        100,
        '¡Prueba de notificación!',
        body,
        notificationDetails,
      );
      
      debugPrint('Notificación de prueba enviada');
    } catch (e) {
      debugPrint('Error al enviar notificación: $e');
    }
  }
  
  // Verificar notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}