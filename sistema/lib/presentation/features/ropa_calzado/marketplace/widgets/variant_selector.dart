import 'package:flutter/material.dart';

class VariantSelector extends StatefulWidget {
  final List<String> availableSizes;
  final List<Map<String, String>> availableColors; // {name, hexCode}
  final List<String> availableMaterials;
  final String? selectedSize;
  final String? selectedColor;
  final String? selectedMaterial;
  final Function(String?) onSizeChanged;
  final Function(String?) onColorChanged;
  final Function(String?) onMaterialChanged;
  final bool showMaterials;

  const VariantSelector({
    Key? key,
    required this.availableSizes,
    required this.availableColors,
    required this.availableMaterials,
    this.selectedSize,
    this.selectedColor,
    this.selectedMaterial,
    required this.onSizeChanged,
    required this.onColorChanged,
    required this.onMaterialChanged,
    this.showMaterials = true,
  }) : super(key: key);

  @override
  State<VariantSelector> createState() => _VariantSelectorState();
}

class _VariantSelectorState extends State<VariantSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de Tallas
        if (widget.availableSizes.isNotEmpty) ...[
          const Text(
            'Talla',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildSizeSelector(),
          const SizedBox(height: 20),
        ],

        // Selector de Colores
        if (widget.availableColors.isNotEmpty) ...[
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildColorSelector(),
          const SizedBox(height: 20),
        ],

        // Selector de Materiales
        if (widget.showMaterials && widget.availableMaterials.isNotEmpty) ...[
          const Text(
            'Material',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildMaterialSelector(),
        ],
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableSizes.map((size) {
        final isSelected = widget.selectedSize == size;
        return GestureDetector(
          onTap: () {
            widget.onSizeChanged(isSelected ? null : size);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEC4899) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.availableColors.map((colorData) {
        final colorName = colorData['name']!;
        final hexCode = colorData['hexCode']!;
        final isSelected = widget.selectedColor == colorName;
        
        return GestureDetector(
          onTap: () {
            widget.onColorChanged(isSelected ? null : colorName);
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse(hexCode.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
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

  Widget _buildMaterialSelector() {
    return Column(
      children: widget.availableMaterials.map((material) {
        final isSelected = widget.selectedMaterial == material;
        return GestureDetector(
          onTap: () {
            widget.onMaterialChanged(isSelected ? null : material);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFEC4899).withOpacity(0.1)
                  : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFEC4899)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.texture,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    material,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFFEC4899) : Colors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFEC4899),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class VariantCombination {
  final String? size;
  final String? color;
  final String? material;
  final double? priceModifier;
  final int stock;
  final String? sku;

  VariantCombination({
    this.size,
    this.color,
    this.material,
    this.priceModifier,
    required this.stock,
    this.sku,
  });

  String get displayName {
    final parts = <String>[];
    if (size != null) parts.add(size!);
    if (color != null) parts.add(color!);
    if (material != null) parts.add(material!);
    return parts.join(' - ');
  }

  bool matches({String? size, String? color, String? material}) {
    return (size == null || this.size == size) &&
           (color == null || this.color == color) &&
           (material == null || this.material == material);
  }
}

class VariantAvailabilityChecker {
  final List<VariantCombination> availableCombinations;

  VariantAvailabilityChecker(this.availableCombinations);

  bool isVariantAvailable({String? size, String? color, String? material}) {
    return availableCombinations.any((combination) =>
        combination.matches(size: size, color: color, material: material) &&
        combination.stock > 0);
  }

  List<String> getAvailableSizes({String? color, String? material}) {
    return availableCombinations
        .where((combination) =>
            combination.matches(color: color, material: material) &&
            combination.stock > 0)
        .map((combination) => combination.size)
        .where((size) => size != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  List<String> getAvailableColors({String? size, String? material}) {
    return availableCombinations
        .where((combination) =>
            combination.matches(size: size, material: material) &&
            combination.stock > 0)
        .map((combination) => combination.color)
        .where((color) => color != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  List<String> getAvailableMaterials({String? size, String? color}) {
    return availableCombinations
        .where((combination) =>
            combination.matches(size: size, color: color) &&
            combination.stock > 0)
        .map((combination) => combination.material)
        .where((material) => material != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  int getStock({String? size, String? color, String? material}) {
    final combination = availableCombinations.firstWhere(
      (combination) => combination.matches(size: size, color: color, material: material),
      orElse: () => VariantCombination(stock: 0),
    );
    return combination.stock;
  }

  double? getPriceModifier({String? size, String? color, String? material}) {
    final combination = availableCombinations.firstWhere(
      (combination) => combination.matches(size: size, color: color, material: material),
      orElse: () => VariantCombination(stock: 0),
    );
    return combination.priceModifier;
  }
}