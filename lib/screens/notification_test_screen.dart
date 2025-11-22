// lib/screens/notification_test_screen.dart (con verificación de permisos)
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import '../widgets/common/permission_dialog.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _isLoading = false;
  List<PendingNotificationRequest> _pendingNotifications = [];
  List<PendingNotificationRequest> _weeklyNotifications = [];
  bool _hasPermissions = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadNotifications();
  }
  
  // Verificar permisos y cargar notificaciones
  Future<void> _checkPermissionsAndLoadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Verificar permisos
      _hasPermissions = await NotificationService.checkPermissions();
      debugPrint('🔔 Estado de permisos: $_hasPermissions');
      
      // Cargar notificaciones
      await _loadPendingNotifications();
    } catch (e) {
      debugPrint('Error al verificar permisos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Cargar las notificaciones pendientes
  Future<void> _loadPendingNotifications() async {
    try {
      final pending = await NotificationService.getPendingNotifications();
      
      // Separar notificaciones semanales de otras
      final weekly = pending.where((n) => n.id >= 1000 && n.id < 1008).toList();
      final others = pending.where((n) => n.id < 1000 || n.id >= 1008).toList();
      
      setState(() {
        _pendingNotifications = others;
        _weeklyNotifications = weekly;
      });
    } catch (e) {
      debugPrint('Error al cargar notificaciones: $e');
    }
  }
  
  // Solicitar permisos explícitamente
  Future<void> _requestPermissions() async {
    final granted = await PermissionDialog.ensureNotificationPermissions(
      context, 
      showDialog: true
    );
    
    setState(() {
      _hasPermissions = granted!;
    });
    
    if (granted!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('¡Permisos otorgados! Ahora puedes programar notificaciones.'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Permisos necesarios para las notificaciones.'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  // Enviar una notificación de prueba inmediata
  Future<void> _sendImmediateNotification() async {
    if (!_hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas otorgar permisos de notificación primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final success = await NotificationService.showImmediateNotification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Notificación inmediata enviada. Revisa la bandeja de notificaciones.'
                : 'Error al enviar la notificación inmediata.'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
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
    if (!_hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas otorgar permisos de notificación primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await NotificationService.scheduleNotificationForTesting();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Notificación programada para 1 minuto después'
                : 'Error al programar la notificación'
          ),
          backgroundColor: success ? Colors.blue : Colors.red,
          duration: const Duration(seconds: 4),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Probar notificaciones semanales con la configuración actual
  Future<void> _testWeeklyNotifications() async {
    if (!_hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas otorgar permisos de notificación primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
      final dayOfWeek = scheduleProvider.getDayOfWeekIndex();
      final time = scheduleProvider.time;
      
      final success = await NotificationService.scheduleWeeklyNotification(
        dayOfWeek: dayOfWeek,
        hour: time.hour,
        minute: time.minute,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Notificaciones semanales configuradas para ${scheduleProvider.day} a las ${time.format(context)}'
                : 'Error al configurar notificaciones semanales'
          ),
          backgroundColor: success ? Colors.purple : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Actualizar la lista
      await _loadPendingNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al configurar notificaciones semanales: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
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
    } finally {
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
            onPressed: _checkPermissionsAndLoadNotifications,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: _isLoading && _pendingNotifications.isEmpty && _weeklyNotifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NUEVA SECCIÓN: Estado de permisos
                    _buildPermissionsStatusCard(),
                    
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
                    
                    // Configuración actual de programación
                    Consumer<ScheduleProvider>(
                      builder: (context, provider, _) {
                        return Card(
                          elevation: 4,
                          color: Colors.purple[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule, color: Colors.purple[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Configuración actual',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Día: ${provider.day}'),
                                Text('Hora: ${provider.time.format(context)}'),
                                Text('Notificaciones: ${provider.notificationsEnabled ? "Habilitadas" : "Deshabilitadas"}'),
                              ],
                            ),
                          ),
                        );
                      },
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
                    
                    // Primera fila de botones
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _hasPermissions ? _sendImmediateNotification : null,
                            icon: const Icon(Icons.notifications_active),
                            label: const Text('Inmediata'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasPermissions ? Colors.green : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _hasPermissions ? _scheduleNotificationIn1Minute : null,
                            icon: const Icon(Icons.schedule),
                            label: const Text('En 1 min'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasPermissions ? Colors.blue : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Segunda fila: notificaciones semanales
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_hasPermissions && !_isLoading) ? _testWeeklyNotifications : null,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.repeat),
                        label: const Text('Probar Notificaciones Semanales'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasPermissions ? Colors.purple : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tercera fila: cancelar todas
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
                    
                    // Notificaciones semanales
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.repeat, color: Colors.purple[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Notificaciones semanales (${_weeklyNotifications.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    _weeklyNotifications.isEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No hay notificaciones semanales programadas',
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
                              itemCount: _weeklyNotifications.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final notification = _weeklyNotifications[index];
                                final weekNumber = (notification.id - 1000) + 1;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.purple[100],
                                    child: Text('S$weekNumber'),
                                  ),
                                  title: Text(notification.title ?? 'Sin título'),
                                  subtitle: Text('ID: ${notification.id}'),
                                  trailing: Icon(
                                    Icons.schedule,
                                    color: Colors.purple[400],
                                  ),
                                );
                              },
                            ),
                          ),
                    
                    const SizedBox(height: 16),
                    
                    // Lista de otras notificaciones pendientes
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Otras notificaciones programadas (${_pendingNotifications.length})',
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
                                  'No hay otras notificaciones programadas',
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
                                    backgroundColor: Colors.blue[100],
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
  
  // NUEVA SECCIÓN: Estado de permisos
  Widget _buildPermissionsStatusCard() {
    return Card(
      elevation: 4,
      color: _hasPermissions ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _hasPermissions ? Icons.check_circle : Icons.warning,
                  color: _hasPermissions ? Colors.green[700] : Colors.red[700],
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado de Permisos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _hasPermissions ? Colors.green[700] : Colors.red[700],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _hasPermissions 
                  ? '✅ Permisos de notificación otorgados'
                  : '❌ Permisos de notificación NO otorgados',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _hasPermissions ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasPermissions 
                  ? 'Puedes usar todas las funciones de notificación.'
                  : 'Necesitas otorgar permisos para usar las notificaciones.',
              style: const TextStyle(fontSize: 14),
            ),
            if (!_hasPermissions) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.security),
                label: const Text('Solicitar Permisos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Información de solución de problemas (actualizada)
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
              'Si las notificaciones no funcionan:',
            ),
            const SizedBox(height: 8),
            const Text(
              '1. PRIMERO: Verifica que tengas permisos arriba ⬆️\n'
              '2. En Android 12+: Ve a Configuración > Apps > Esta App > Permisos > Alarmas y recordatorios\n'
              '3. Desactiva la optimización de batería para esta app\n'
              '4. Reinicia el dispositivo si es necesario',
            ),
            const SizedBox(height: 8),
            const Text(
              'Si ves las 8 notificaciones semanales listadas arriba Y tienes permisos, entonces están funcionando correctamente.',
              style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}