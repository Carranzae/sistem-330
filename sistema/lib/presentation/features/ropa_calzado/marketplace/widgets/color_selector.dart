import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<String> colors;
  final String? selectedColor;
  final Function(String) onColorSelected;

  const ColorSelector({
    Key? key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rosa':
        return const Color(0xFFEC4899);
      case 'negro':
        return Colors.black;
      case 'azul':
        return Colors.blue;
      case 'blanco':
        return Colors.white;
      case 'rojo':
        return Colors.red;
      case 'verde':
        return Colors.green;
      case 'amarillo':
        return Colors.yellow;
      case 'morado':
        return Colors.purple;
      case 'naranja':
        return Colors.orange;
      case 'gris':
        return Colors.grey;
      case 'marrón':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((colorName) {
        final isSelected = selectedColor == colorName;
        final color = _getColorFromName(colorName);
        
        return GestureDetector(
          onTap: () => onColorSelected(colorName),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: colorName.toLowerCase() == 'blanco'
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                colorName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFEC4899) : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}