// lib/screens/schedule_settings_screen.dart (con verificación de permisos)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../services/notification_service.dart';
import '../widgets/common/permission_dialog.dart';

class ScheduleSettingsScreen extends StatefulWidget {
  const ScheduleSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends State<ScheduleSettingsScreen> {
  final List<String> _days = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 
    'Viernes', 'Sábado', 'Domingo'
  ];
  
  late String _selectedDay;
  late TimeOfDay _selectedTime;
  bool _notificationsEnabled = true;
  bool _isSaving = false;
  bool _hasPermissions = false;
  
  @override
  void initState() {
    super.initState();
    
    // Obtener la configuración actual del provider
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    _selectedDay = scheduleProvider.day;
    _selectedTime = scheduleProvider.time;
    _notificationsEnabled = scheduleProvider.notificationsEnabled;
    
    // Verificar permisos al inicio
    _checkPermissions();
  }
  
  // Verificar permisos de notificación
  Future<void> _checkPermissions() async {
    final hasPermissions = await NotificationService.checkPermissions();
    setState(() {
      _hasPermissions = hasPermissions;
    });
  }
  
  void _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodBorderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }
  
  Future<void> _saveSchedule() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // VERIFICAR PERMISOS SI LAS NOTIFICACIONES ESTÁN HABILITADAS
      if (_notificationsEnabled) {
        if (!_hasPermissions) {
          debugPrint('🔔 Sin permisos, solicitando...');
          final granted = await PermissionDialog.ensureNotificationPermissions(
            context, 
            showDialog: true
          );
          
          if (!granted!) {
            // Si no se otorgan permisos, deshabilitar notificaciones automáticamente
            setState(() {
              _notificationsEnabled = false;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Configuración guardada sin notificaciones. Puedes activarlas después otorgando permisos.'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          } else {
            setState(() {
              _hasPermissions = true;
            });
          }
        }
      }
      
      // Guardar la configuración en el provider
      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
      await scheduleProvider.setSchedule(_selectedDay, _selectedTime);
      
      // Actualizar el estado de las notificaciones
      await scheduleProvider.toggleNotifications(_notificationsEnabled);
      
      if (_notificationsEnabled && _hasPermissions) {
        // Programar la notificación
        final dayOfWeek = _days.indexOf(_selectedDay) + 1; // 1 = lunes, 7 = domingo
        final success = await NotificationService.scheduleWeeklyNotification(
          dayOfWeek: dayOfWeek,
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      success 
                          ? 'Notificaciones programadas correctamente'
                          : 'Configuración guardada, pero verifica los permisos de notificación'
                    ),
                  ),
                ],
              ),
              backgroundColor: success ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (!_notificationsEnabled) {
        // Cancelar notificaciones existentes
        await NotificationService.cancelWeeklyNotifications();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.notifications_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Notificaciones desactivadas'),
                ],
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error al guardar la programación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al guardar la configuración: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Formatear la hora seleccionada
    final formattedTime = DateFormat('h:mm a').format(
      DateTime(2022, 1, 1, _selectedTime.hour, _selectedTime.minute)
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Programación'),
        actions: [
          _isSaving 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Guardar',
                onPressed: _saveSchedule,
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NUEVA SECCIÓN: Estado de permisos
            Card(
              elevation: 4,
              color: _hasPermissions ? Colors.green[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasPermissions ? Icons.check_circle : Icons.warning,
                          color: _hasPermissions ? Colors.green[700] : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Estado de Permisos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _hasPermissions ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasPermissions 
                          ? 'Permisos de notificación otorgados ✅'
                          : 'Permisos de notificación necesarios ⚠️',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (!_hasPermissions) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final granted = await PermissionDialog.ensureNotificationPermissions(
                            context, 
                            showDialog: true
                          );
                          setState(() {
                            _hasPermissions = granted!;
                          });
                        },
                        icon: const Icon(Icons.security),
                        label: const Text('Solicitar Permisos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tarjeta principal
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Programa tu tiempo de juegos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configura cuándo quieres recibir un recordatorio para tu tiempo de juegos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Selector de día
                    const Text(
                      'Día de la semana',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDay,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      ),
                      items: _days.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDay = value;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Selector de hora
                    const Text(
                      'Hora',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showTimePicker,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode 
                                ? Colors.grey[700]! 
                                : Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Switch para habilitar/deshabilitar notificaciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notificaciones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              _hasPermissions 
                                  ? 'Recibir recordatorios semanales'
                                  : 'Requiere permisos (ver arriba)',
                              style: TextStyle(
                                fontSize: 14,
                                color: _hasPermissions 
                                    ? (isDarkMode ? Colors.grey[400] : Colors.grey[700])
                                    : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _notificationsEnabled && _hasPermissions,
                          onChanged: _hasPermissions 
                              ? (value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                }
                              : null,
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDarkMode 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
                  : Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '¿Cómo funciona?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'La app te enviará una notificación el día y hora seleccionados para recordarte que es momento de realizar tu tiempo de juegos.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'La notificación se repetirá cada semana en el mismo día y hora.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botones
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSchedule,
                    icon: _isSaving 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ) 
                        : const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}