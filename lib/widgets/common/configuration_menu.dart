// lib/widgets/common/configuration_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../providers/teams_provider.dart';
import '../../providers/game_provider.dart';
import '../../screens/team_config_screen.dart';

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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
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
          // Opciones de configuración
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.groups, color: Colors.white),
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
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.refresh, color: Colors.white),
            ),
            title: const Text('Reiniciar Juego'),
            subtitle: const Text('Borra puntuaciones y juegos'),
            onTap: () {
              Navigator.pop(context);
              _showResetConfirmationDialog(context, teamsProvider, gameProvider);
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.delete, color: Colors.white),
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
              gameProvider.addGame(); // Añadir un juego inicial
              Navigator.pop(context);
              
              // Mostrar mensaje de confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Juego reiniciado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
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
                
                // Reiniciar la aplicación (opcional)
                // Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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