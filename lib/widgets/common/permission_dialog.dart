// lib/widgets/common/permission_dialog.dart
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import 'dart:io' show Platform;

class PermissionDialog {
  
  // Mostrar diálogo de solicitud de permisos
  static Future<bool> showNotificationPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // No se puede cancelar tocando fuera
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Permisos de Notificación',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para enviarte recordatorios de tu tiempo de juegos, necesitamos acceso a las notificaciones.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Recordatorios semanales',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'No interrumpiremos en otros momentos',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 12),
              const Text(
                'Se abrirá la configuración del sistema donde podrás permitir las notificaciones.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop(true);
              // Solicitar permisos inmediatamente
              await NotificationService.requestPermissions();
            },
            icon: const Icon(Icons.notifications),
            label: const Text('Permitir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // Verificar permisos y mostrar diálogo si es necesario
  static Future<bool?> ensureNotificationPermissions(BuildContext context, {bool showDialog = true}) async {
    // Verificar si ya tenemos permisos
    final hasPermissions = await NotificationService.checkPermissions();
    
    if (hasPermissions) {
      debugPrint('✅ Ya tenemos permisos de notificación');
      return true;
    }
    
    if (!showDialog) {
      // Solo solicitar sin mostrar diálogo
      return await NotificationService.requestPermissions();
    }
    
    // Mostrar diálogo explicativo y luego solicitar
    if (context.mounted) {
      final userAgreed = await showNotificationPermissionDialog(context);
      
      if (userAgreed) {
        // Usuario aceptó, ahora verificar si realmente se otorgaron
        final finalCheck = await NotificationService.checkPermissions();
        debugPrint('🔔 Permisos después de solicitud: $finalCheck');
        return finalCheck;
      }
    }
    
    return false;
  }
  
  // Mostrar diálogo informativo sobre permisos denegados
  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_off,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Permisos necesarios'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sin permisos de notificación no podremos enviarte recordatorios.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Puedes activarlos manualmente en:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                Platform.isAndroid 
                    ? 'Configuración > Apps > Awana Games > Notificaciones'
                    : 'Configuración > Notificaciones > Awana Games',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Intentar solicitar nuevamente
              await NotificationService.requestPermissions();
            },
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
}