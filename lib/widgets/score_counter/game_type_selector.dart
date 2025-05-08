// lib/widgets/score_counter/game_type_selector.dart
import 'package:flutter/material.dart';
import '../../models/game.dart';

class GameTypeSelector extends StatelessWidget {
  final GameType selectedType;
  final Function(GameType) onTypeSelected;
  final bool isDisabled; // Nueva propiedad para deshabilitar el selector
  final bool isVertical;

  const GameTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
    this.isDisabled = false, // Por defecto no está deshabilitado
    this.isVertical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isVertical
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SelectorButton(
              text: 'Juego Normal',
              isSelected: selectedType == GameType.normal,
              onTap: isDisabled ? null : () => onTypeSelected(GameType.normal),
              isDisabled: isDisabled,
            ),
            const SizedBox(height: 16),
            _SelectorButton(
              text: 'Juego por Rondas',
              isSelected: selectedType == GameType.rounds,
              onTap: isDisabled ? null : () => onTypeSelected(GameType.rounds),
              isDisabled: isDisabled,
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SelectorButton(
              text: 'Juego Normal',
              isSelected: selectedType == GameType.normal,
              onTap: isDisabled ? null : () => onTypeSelected(GameType.normal),
              isDisabled: isDisabled,
            ),
            const SizedBox(width: 8),
            _SelectorButton(
              text: 'Juego por Rondas',
              isSelected: selectedType == GameType.rounds,
              onTap: isDisabled ? null : () => onTypeSelected(GameType.rounds),
              isDisabled: isDisabled,
            ),
          ],
        );
  }
}

class _SelectorButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _SelectorButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
          ? Colors.purple 
          : (isDisabled ? Colors.grey[300] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected && !isDisabled
          ? [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : (isDisabled ? Colors.grey : Colors.black87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDisabled) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}