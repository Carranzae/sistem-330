import 'package:flutter/material.dart';

class BusinessCategoryStep extends StatefulWidget {
  final Function(String) onCategorySelected;
  final VoidCallback? onNext;

  const BusinessCategoryStep({
    super.key,
    required this.onCategorySelected,
    this.onNext,
  });

  @override
  State<BusinessCategoryStep> createState() => _BusinessCategoryStepState();
}

class _BusinessCategoryStepState extends State<BusinessCategoryStep> {
  String? _selectedCategory;

  // Categorías profesionales de negocio
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'abarrotes',
      'name': 'Abarrotes / Bodega',
      'icon': Icons.store,
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'ropa_calzado',
      'name': 'Ropa, Calzado y Accesorios',
      'icon': Icons.checkroom,
      'color': const Color(0xFFEC4899),
    },
    {
      'id': 'hogar_decoracion',
      'name': 'Hogar y Decoración',
      'icon': Icons.home,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'electronica',
      'name': 'Electrónica y Tecnología',
      'icon': Icons.smartphone,
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': 'verduleria',
      'name': 'Verdulería / Frutas',
      'icon': Icons.eco,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'papa_mayorista',
      'name': 'Venta de Papa / Tubérculos',
      'icon': Icons.agriculture,
      'color': const Color(0xFFF97316),
    },
    {
      'id': 'carniceria',
      'name': 'Carnicería / Pollería',
      'icon': Icons.restaurant,
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'ferreteria',
      'name': 'Ferretería / Construcción',
      'icon': Icons.build,
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'farmacia',
      'name': 'Farmacia / Botica',
      'icon': Icons.local_pharmacy,
      'color': const Color(0xFF06B6D4),
    },
    {
      'id': 'restaurante',
      'name': 'Restaurante / Comida',
      'icon': Icons.restaurant_menu,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'id': 'mayorista',
      'name': 'Mayorista / Distribuidor',
      'icon': Icons.inventory_2,
      'color': const Color(0xFF9333EA),
    },
    {
      'id': 'otro',
      'name': 'Otro / General',
      'icon': Icons.category,
      'color': const Color(0xFF64748B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header con navegación
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Contenido con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      '¿Cuál es tu rubro?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona la categoría que mejor describe tu negocio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Grid de categorías
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category['id'];
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category['id'] as String;
                            });
                            widget.onCategorySelected(category['id'] as String);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (category['color'] as Color).withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? category['color'] as Color
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 2.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (category['color'] as Color).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (category['color'] as Color).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    color: category['color'] as Color,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    category['name'] as String,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected
                                          ? category['color'] as Color
                                          : const Color(0xFF1F2937),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: category['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
                // Botón continuar (si hay categoría seleccionada)
            if (_selectedCategory != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

