// lib/widgets/score_counter/number_grid.dart
import 'package:flutter/material.dart';

// lib/widgets/score_counter/number_grid.dart
class NumberGrid extends StatelessWidget {
  final List<int> selectedNumbers;
  final Function(int) onNumberSelected;
  final int maxNumbers;
  final Function() onAddNumber;

  const NumberGrid({
    Key? key,
    required this.selectedNumbers,
    required this.onNumberSelected,
    required this.maxNumbers,
    required this.onAddNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona números',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: maxNumbers < 50 ? maxNumbers + 1 : maxNumbers,
              itemBuilder: (context, index) {
                if (index == maxNumbers && maxNumbers < 50) {
                  // Botón de añadir
                  return ElevatedButton(
                    onPressed: onAddNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      foregroundColor: Colors.purple,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.add),
                  );
                }

                final number = index + 1;
                final isSelected = selectedNumbers.contains(number);

                return ElevatedButton(
                  onPressed: isSelected ? null : () => onNumberSelected(number),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.grey[300] : Colors.purple[100],
                    foregroundColor: isSelected ? Colors.grey[600] : Colors.purple,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}