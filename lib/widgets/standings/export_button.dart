// lib/widgets/standings/export_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teams_provider.dart';
import '../../providers/game_provider.dart';
import '../../services/export_service.dart';
import '../../widgets/standings/standings_table.dart';

class ExportButton extends StatelessWidget {
  final GlobalKey<StandingsTableState> tableKey;
  
  const ExportButton({
    Key? key, 
    required this.tableKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showExportOptions(context),
      icon: const Icon(Icons.share),
      label: const Text('Exportar'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _showExportOptions(BuildContext context) {
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
          const SizedBox(height: 20),
          const Text(
            'Exportar Resultados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // PDF Option
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.picture_as_pdf, color: Colors.white),
            ),
            title: const Text('Exportar como PDF'),
            subtitle: const Text('Formato para imprimir o compartir'),
            onTap: () {
              Navigator.pop(context);
              ExportService.exportToPdf(
                teams: teamsProvider.teams,
                games: gameProvider.games,
                context: context,
              );
            },
          ),
          
          // CSV Option
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.table_chart, color: Colors.white),
            ),
            title: const Text('Exportar como CSV'),
            subtitle: const Text('Para abrir en Excel u otras hojas de cálculo'),
            onTap: () {
              Navigator.pop(context);
              ExportService.exportToCsv(
                teams: teamsProvider.teams,
                games: gameProvider.games,
                context: context,
              );
            },
          ),
          
          // New Image Option
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.image, color: Colors.white),
            ),
            title: const Text('Exportar como Imagen'),
            subtitle: const Text('Para compartir en redes sociales o mensajería'),
            onTap: () {
              Navigator.pop(context);
              // Check if we have access to the table widget state
              if (tableKey.currentState != null) {
                ExportService.exportToImageUsingBoundary(
                  tableKey: tableKey.currentState!.tableKey,
                  context: context,
                );
              } else {
                // Show error if we can't access the table
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo acceder a la tabla para exportar'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          
          const SizedBox(height: 20),
          
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}