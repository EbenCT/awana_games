// lib/widgets/score_counter/number_grid.dart
import 'package:flutter/material.dart';

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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final crossAxisCount = isSmallScreen ? 4 : 5;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Añadido para prevenir expansión infinita
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecciona números',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedNumbers.length}/$maxNumbers',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Usamos un GridView con tamaño fijo en lugar de Expanded
            SizedBox(
              height: 300, // Altura fija para el grid
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: maxNumbers < 50 ? maxNumbers + 1 : maxNumbers,
                itemBuilder: (context, index) {
                  if (index == maxNumbers && maxNumbers < 50) {
                    // Botón de añadir
                    return _buildAddButton();
                  }
                  
                  final number = index + 1;
                  final isSelected = selectedNumbers.contains(number);
                  
                  return _buildNumberButton(number, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddNumber,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.purple[200]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.purple[400],
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNumberButton(int number, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
            ? Colors.grey[300] 
            : Colors.purple[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelected ? null : () => onNumberSelected(number),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.grey[600] 
                    : Colors.purple[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}