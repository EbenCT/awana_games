// lib/screens/notification_test_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _isLoading = false;
  List<PendingNotificationRequest> _pendingNotifications = [];
  
  @override
  void initState() {
    super.initState();
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
        _pendingNotifications = pending;
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
      await NotificationService.showImmediateNotification();
      
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
  
  // Programar una notificación para 1 minuto después
  Future<void> _scheduleNotificationIn1Minute() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await NotificationService.scheduleNotificationForTesting();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación programada para 1 minuto después'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Actualizar la lista de notificaciones pendientes
      await _loadPendingNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al programar la notificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Cancelar todas las notificaciones
  Future<void> _cancelAllNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await NotificationService.cancelAllNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas las notificaciones han sido canceladas'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Actualizar la lista de notificaciones pendientes
      await _loadPendingNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar las notificaciones: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de información de permisos
                    _buildPermissionsInfoCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Información de zona horaria
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información de zona horaria',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Zona configurada: ${tz.local.name}'),
                            Text('Hora actual: ${DateFormat('HH:mm:ss').format(DateTime.now())}'),
                            Text('Offset: ${DateTime.now().timeZoneOffset.inHours}h ${DateTime.now().timeZoneOffset.inMinutes % 60}m'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botones de acción
                    const Text(
                      'Acciones de prueba',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _scheduleNotificationIn1Minute,
                            icon: const Icon(Icons.schedule),
                            label: const Text('Notificación en 1 min'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Lista de notificaciones pendientes
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Notificaciones programadas (${_pendingNotifications.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    _pendingNotifications.isEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No hay notificaciones programadas',
                                  style: TextStyle(
                                    color: isDarkMode 
                                        ? Colors.grey[400] 
                                        : Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pendingNotifications.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final notification = _pendingNotifications[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.purple[100],
                                    child: Text('${notification.id}'),
                                  ),
                                  title: Text(notification.title ?? 'Sin título'),
                                  subtitle: Text(notification.body ?? 'Sin contenido'),
                                );
                              },
                            ),
                          ),
                          
                    // Información sobre solución de problemas
                    const SizedBox(height: 24),
                    _buildTroubleshootingCard(),
                  ],
                ),
              ),
            ),
    );
  }
  
  // Información de permisos
  Widget _buildPermissionsInfoCard() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Información de permisos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Para que las notificaciones programadas funcionen correctamente, asegúrate de:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Tener habilitadas las notificaciones para esta app\n'
              '• En Android 12+, permitir "Alarmas y recordatorios"\n'
              '• Desactivar la optimización de batería para esta app',
            ),
            const SizedBox(height: 8),
            if (Platform.isAndroid)
              OutlinedButton.icon(
                onPressed: () {
                  // Simplemente mostrar instrucciones
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ajustes manuales necesarios'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Por favor, ve a los ajustes de tu dispositivo:\n\n'
                          '1. Configuración > Apps > [Esta App] > Notificaciones\n\n'
                          '2. Configuración > Apps > [Esta App] > Batería > Sin restricciones\n\n'
                          '3. En Android 12 o superior, también:\n'
                          'Configuración > Apps > [Esta App] > Permisos > Alarmas y recordatorios',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Ver instrucciones de configuración'),
              ),
          ],
        ),
      ),
    );
  }
  
  // Información de solución de problemas
  Widget _buildTroubleshootingCard() {
    return Card(
      elevation: 4,
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'Solución de problemas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Si las notificaciones programadas no funcionan:',
            ),
            const SizedBox(height: 8),
            const Text(
              '• Reinicia tu dispositivo\n'
              '• Desinstala y reinstala la aplicación\n'
              '• En algunos dispositivos (Xiaomi, Huawei, etc.) debes desactivar manualmente las "restricciones de fondo"\n'
              '• Prueba aumentar el tiempo a más de 1 minuto (algunos dispositivos tienen limitaciones)',
            ),
            const SizedBox(height: 8),
            const Text(
              'Las notificaciones inmediatas funcionan de forma diferente a las programadas. Si las inmediatas funcionan pero las programadas no, es probable que sea un problema de permisos o restricciones del sistema.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}