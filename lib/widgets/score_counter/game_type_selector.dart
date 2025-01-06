// lib/widgets/score_counter/game_type_selector.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';

class GameTypeSelector extends StatelessWidget {
  final GameType selectedType;
  final Function(GameType) onTypeSelected;

  const GameTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SelectorButton(
          text: 'Juego Normal',
          isSelected: selectedType == GameType.normal,
          onTap: () => onTypeSelected(GameType.normal),
        ),
        const SizedBox(width: 8),
        _SelectorButton(
          text: 'Juego por Rondas',
          isSelected: selectedType == GameType.rounds,
          onTap: () => onTypeSelected(GameType.rounds),
        ),
      ],
    );
  }
}

class _SelectorButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectorButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.purple : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}