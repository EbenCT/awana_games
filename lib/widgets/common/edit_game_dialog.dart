// lib/widgets/common/edit_game_dialog.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../providers/game_provider.dart';
import 'package:provider/provider.dart';

class EditGameDialog extends StatelessWidget {
  final Game game;
  final int gameIndex;

  const EditGameDialog({
    Key? key,
    required this.game,
    required this.gameIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: game.name);

    return AlertDialog(
      title: const Text('Editar nombre del juego'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Nombre del juego',
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
        maxLength: 30,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty) {
              Provider.of<GameProvider>(context, listen: false)
                  .updateGameName(gameIndex, newName);
            }
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}