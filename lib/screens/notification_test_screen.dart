// lib/screens/notification_test_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_test.dart';
import '../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _pendingNotifications = [];
  
  @override
  void initState() {
    super.initState();
    // Inicializar el servicio de prueba
    NotificationTest.initialize();
    // Cargar las notificaciones pendientes al inicio
    _loadPendingNotifications();
  }
  
  // Cargar las notificaciones pendientes
  Future<void> _loadPendingNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pending = await NotificationService.getPendingNotifications();
      
      setState(() {
        _pendingNotifications = pending.map((notification) => {
          'id': notification.id,
          'title': notification.title ?? 'Sin título',
          'body': notification.body ?? 'Sin contenido',
        }).toList();
      });
    } catch (e) {
      debugPrint('Error al cargar notificaciones: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Enviar una notificación de prueba inmediata
  Future<void> _sendImmediateNotification() async {
    try {
      await NotificationTest.showTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba enviada. Revisa la bandeja de notificaciones.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la notificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Programar una notificación para unos minutos después
  Future<void> _scheduleNotificationIn5Minutes() async {
    try {
      // Cancelar notificaciones existentes
      await NotificationService.cancelGameNotification();
      
      // Obtener fecha y hora actuales
      final now = tz.TZDateTime.now(tz.local);
      final localTime = DateTime.now();
      
      // Programar para 5 minutos después
      final scheduledTime = now.add(const Duration(minutes: 1));
      
      // Programar la notificación manualmente
      await NotificationService.scheduleNotificationForTesting(scheduledTime);
      
      // Formatear la hora para mostrarla
      final formattedTime = DateFormat('HH:mm:ss').format(
        localTime.add(const Duration(minutes: 1))
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notificación programada para las $formattedTime (en 1 minutos)'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Actualizar la lista de notificaciones pendientes
      _loadPendingNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al programar la notificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Cancelar todas las notificaciones
  Future<void> _cancelAllNotifications() async {
    try {
      await NotificationService.cancelAllNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas las notificaciones han sido canceladas'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Actualizar la lista de notificaciones pendientes
      _loadPendingNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar las notificaciones: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingNotifications,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de información
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDarkMode 
                  ? Colors.indigo[900] 
                  : Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDarkMode 
                              ? Colors.indigo[200] 
                              : Colors.indigo,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Prueba de notificaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode 
                                ? Colors.indigo[200] 
                                : Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Utiliza esta pantalla para probar que las notificaciones funcionan correctamente en tu dispositivo.',
                      style: TextStyle(
                        color: isDarkMode 
                            ? Colors.grey[300] 
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Text(
              'Acciones de prueba',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? Colors.grey[300] 
                    : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendImmediateNotification,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Notificación inmediata'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _scheduleNotificationIn5Minutes,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Notificación en 5 min'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cancelAllNotifications,
                icon: const Icon(Icons.notifications_off),
                label: const Text('Cancelar todas las notificaciones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lista de notificaciones pendientes
            Text(
              'Notificaciones programadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? Colors.grey[300] 
                    : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _pendingNotifications.isEmpty
                      ? Center(
                          child: Text(
                            'No hay notificaciones programadas',
                            style: TextStyle(
                              color: isDarkMode 
                                  ? Colors.grey[400] 
                                  : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _pendingNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = _pendingNotifications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple[100],
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.purple[700],
                                  ),
                                ),
                                title: Text(notification['title']),
                                subtitle: Text(notification['body']),
                                trailing: Text(
                                  'ID: ${notification['id']}',
                                  style: TextStyle(
                                    color: isDarkMode 
                                        ? Colors.grey[400] 
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}