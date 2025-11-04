import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VariantManagerPage extends StatefulWidget {
  const VariantManagerPage({Key? key}) : super(key: key);

  @override
  State<VariantManagerPage> createState() => _VariantManagerPageState();
}

class _VariantManagerPageState extends State<VariantManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Datos simulados de variantes
  List<SizeVariant> sizes = [
    SizeVariant(id: '1', name: 'XS', category: 'Ropa', isActive: true, order: 1),
    SizeVariant(id: '2', name: 'S', category: 'Ropa', isActive: true, order: 2),
    SizeVariant(id: '3', name: 'M', category: 'Ropa', isActive: true, order: 3),
    SizeVariant(id: '4', name: 'L', category: 'Ropa', isActive: true, order: 4),
    SizeVariant(id: '5', name: 'XL', category: 'Ropa', isActive: true, order: 5),
    SizeVariant(id: '6', name: 'XXL', category: 'Ropa', isActive: true, order: 6),
    SizeVariant(id: '7', name: '36', category: 'Calzado', isActive: true, order: 1),
    SizeVariant(id: '8', name: '37', category: 'Calzado', isActive: true, order: 2),
    SizeVariant(id: '9', name: '38', category: 'Calzado', isActive: true, order: 3),
    SizeVariant(id: '10', name: '39', category: 'Calzado', isActive: true, order: 4),
  ];

  List<ColorVariant> colors = [
    ColorVariant(id: '1', name: 'Negro', hexCode: '#000000', isActive: true),
    ColorVariant(id: '2', name: 'Blanco', hexCode: '#FFFFFF', isActive: true),
    ColorVariant(id: '3', name: 'Rojo', hexCode: '#FF0000', isActive: true),
    ColorVariant(id: '4', name: 'Azul', hexCode: '#0000FF', isActive: true),
    ColorVariant(id: '5', name: 'Verde', hexCode: '#00FF00', isActive: true),
    ColorVariant(id: '6', name: 'Rosa', hexCode: '#EC4899', isActive: true),
    ColorVariant(id: '7', name: 'Amarillo', hexCode: '#FFFF00', isActive: true),
    ColorVariant(id: '8', name: 'Morado', hexCode: '#800080', isActive: true),
  ];

  List<MaterialVariant> materials = [
    MaterialVariant(id: '1', name: 'Algodón', description: '100% algodón natural', isActive: true),
    MaterialVariant(id: '2', name: 'Poliéster', description: 'Fibra sintética resistente', isActive: true),
    MaterialVariant(id: '3', name: 'Cuero', description: 'Cuero genuino', isActive: true),
    MaterialVariant(id: '4', name: 'Denim', description: 'Tela de mezclilla', isActive: true),
    MaterialVariant(id: '5', name: 'Lana', description: 'Lana natural', isActive: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestión de Variantes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC4899),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.straighten), text: 'Tallas'),
            Tab(icon: Icon(Icons.palette), text: 'Colores'),
            Tab(icon: Icon(Icons.texture), text: 'Materiales'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSizesTab(),
          _buildColorsTab(),
          _buildMaterialsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVariantDialog(),
        backgroundColor: const Color(0xFFEC4899),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSizesTab() {
    final ropaSize = sizes.where((s) => s.category == 'Ropa').toList();
    final calzadoSizes = sizes.where((s) => s.category == 'Calzado').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Tallas de Ropa', ropaSize.length),
          const SizedBox(height: 12),
          _buildSizeGrid(ropaSize),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader('Tallas de Calzado', calzadoSizes.length),
          const SizedBox(height: 12),
          _buildSizeGrid(calzadoSizes),
          
          const SizedBox(height: 24),
          
          _buildAddSizeButton(),
        ],
      ),
    );
  }

  Widget _buildColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Colores Disponibles', colors.length),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return _buildColorCard(color);
            },
          ),
          
          const SizedBox(height: 24),
          
          _buildAddColorButton(),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Materiales', materials.length),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return _buildMaterialCard(material);
            },
          ),
          
          const SizedBox(height: 24),
          
          _buildAddMaterialButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count items',
            style: const TextStyle(
              color: Color(0xFFEC4899),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeGrid(List<SizeVariant> sizeList) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizeList.map((size) => _buildSizeChip(size)).toList(),
    );
  }

  Widget _buildSizeChip(SizeVariant size) {
    return GestureDetector(
      onTap: () => _editSize(size),
      onLongPress: () => _showSizeOptions(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: size.isActive ? const Color(0xFFEC4899) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: size.isActive ? const Color(0xFFEC4899) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          size.name,
          style: TextStyle(
            color: size.isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildColorCard(ColorVariant color) {
    return GestureDetector(
      onTap: () => _editColor(color),
      onLongPress: () => _showColorOptions(color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.isActive ? const Color(0xFFEC4899) : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(int.parse(color.hexCode.replaceFirst('#', '0xFF'))),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    color.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    color.hexCode,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (!color.isActive)
              Icon(
                Icons.visibility_off,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(MaterialVariant material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: material.isActive 
                ? const Color(0xFFEC4899).withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.texture,
            color: material.isActive ? const Color(0xFFEC4899) : Colors.grey[400],
          ),
        ),
        title: Text(
          material.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: material.isActive ? Colors.black : Colors.grey[600],
          ),
        ),
        subtitle: Text(
          material.description,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: PopupMenuButton(
          onSelected: (value) => _handleMaterialAction(value, material),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: material.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(material.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(material.isActive ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _editMaterial(material),
      ),
    );
  }

  Widget _buildAddSizeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddSizeDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Nueva Talla'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEC4899),
          side: const BorderSide(color: Color(0xFFEC4899)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAddColorButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddColorDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Nuevo Color'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEC4899),
          side: const BorderSide(color: Color(0xFFEC4899)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAddMaterialButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddMaterialDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Nuevo Material'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEC4899),
          side: const BorderSide(color: Color(0xFFEC4899)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showAddVariantDialog() {
    final currentTab = _tabController.index;
    switch (currentTab) {
      case 0:
        _showAddSizeDialog();
        break;
      case 1:
        _showAddColorDialog();
        break;
      case 2:
        _showAddMaterialDialog();
        break;
    }
  }

  void _showAddSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nueva Talla'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre de la talla',
                hintText: 'Ej: XL, 42, etc.',
              ),
            ),
            SizedBox(height: 16),
            // Dropdown para categoría
            // TextField para orden
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddColorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Color'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del color',
                hintText: 'Ej: Azul marino',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Código hexadecimal',
                hintText: '#000000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Material'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del material',
                hintText: 'Ej: Seda',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe las características...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Gestión de Variantes'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tallas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Toca para editar una talla\n• Mantén presionado para más opciones\n• Organiza por categoría (Ropa/Calzado)'),
              SizedBox(height: 16),
              Text(
                'Colores:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Usa códigos hexadecimales válidos\n• Los colores inactivos no aparecen en productos'),
              SizedBox(height: 16),
              Text(
                'Materiales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Describe las características del material\n• Útil para filtros y búsquedas'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _editSize(SizeVariant size) {
    // Implementar edición de talla
  }

  void _showSizeOptions(SizeVariant size) {
    // Mostrar opciones para la talla
  }

  void _editColor(ColorVariant color) {
    // Implementar edición de color
  }

  void _showColorOptions(ColorVariant color) {
    // Mostrar opciones para el color
  }

  void _editMaterial(MaterialVariant material) {
    // Implementar edición de material
  }

  void _handleMaterialAction(String action, MaterialVariant material) {
    switch (action) {
      case 'edit':
        _editMaterial(material);
        break;
      case 'activate':
      case 'deactivate':
        setState(() {
          material.isActive = !material.isActive;
        });
        break;
      case 'delete':
        _deleteMaterial(material);
        break;
    }
  }

  void _deleteMaterial(MaterialVariant material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: Text('¿Estás seguro de que quieres eliminar "${material.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                materials.remove(material);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class SizeVariant {
  final String id;
  final String name;
  final String category;
  bool isActive;
  final int order;

  SizeVariant({
    required this.id,
    required this.name,
    required this.category,
    required this.isActive,
    required this.order,
  });
}

class ColorVariant {
  final String id;
  final String name;
  final String hexCode;
  bool isActive;

  ColorVariant({
    required this.id,
    required this.name,
    required this.hexCode,
    required this.isActive,
  });
}

class MaterialVariant {
  final String id;
  final String name;
  final String description;
  bool isActive;

  MaterialVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });
}