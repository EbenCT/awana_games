// lib/widgets/common/configuration_menu.dart (actualizado con prueba de notificaciones)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../providers/teams_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../screens/team_config_screen.dart';
import '../common/theme_toggle.dart';

class ConfigurationMenu extends StatelessWidget {
  const ConfigurationMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Configuración',
      onPressed: () => _showConfigMenu(context),
    );
  }

  void _showConfigMenu(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Toggle de tema
                  const ThemeToggle(),
                  const Divider(),
                  
                  // Opción para configurar programación
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Programación de Juegos'),
                    subtitle: Consumer<ScheduleProvider>(
                      builder: (context, provider, _) {
                        final formattedSchedule = provider.getFormattedSchedule();
                        return Text(formattedSchedule);
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/schedule_settings');
                    },
                  ),
                  
                  // NUEVA OPCIÓN: Probar notificaciones
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      child: const Icon(
                        Icons.bug_report,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text('Probar Notificaciones'),
                    subtitle: const Text('Verificar que funcionan correctamente'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notification_test');
                    },
                  ),
                  
                  const Divider(),
                  
                  // Opciones de configuración
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.groups,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Configurar Equipos'),
                    subtitle: const Text('Cambiar nombres y colores'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeamConfigScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // Opción para reconfigurar juegos
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.sports_esports,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Configurar Juegos'),
                    subtitle: const Text('Modificar cantidad y nombres de juegos'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/game_config');
                    },
                  ),
                  
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.purple,
                      ),
                    ),
                    title: const Text('Reiniciar Juego'),
                    subtitle: const Text('Borra puntuaciones y juegos'),
                    onTap: () {
                      Navigator.pop(context);
                      _showResetConfirmationDialog(context, teamsProvider, gameProvider);
                    },
                  ),
                  
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text('Borrar Datos Guardados'),
                    subtitle: const Text('Elimina todos los datos almacenados'),
                    onTap: () {
                      Navigator.pop(context);
                      _showClearDataConfirmationDialog(context);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showResetConfirmationDialog(
    BuildContext context,
    TeamsProvider teamsProvider,
    GameProvider gameProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Juego'),
        content: const Text(
          '¿Estás seguro de que quieres reiniciar el juego? '
          'Se borrarán todas las puntuaciones y juegos actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              teamsProvider.resetScores();
              gameProvider.resetGames();
              Navigator.pop(context);
              // Navegar a la pantalla de configuración de juegos
              Navigator.pushNamed(context, '/game_config');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar Datos'),
        content: const Text(
          '¿Estás seguro de que quieres borrar todos los datos guardados? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearAllData();
              Navigator.pop(context);
              // Mostrar mensaje de confirmación
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos borrados correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Reiniciar la aplicación
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );
  }
}