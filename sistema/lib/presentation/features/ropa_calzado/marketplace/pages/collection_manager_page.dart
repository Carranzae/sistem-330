import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CollectionManagerPage extends StatefulWidget {
  const CollectionManagerPage({Key? key}) : super(key: key);

  @override
  State<CollectionManagerPage> createState() => _CollectionManagerPageState();
}

class _CollectionManagerPageState extends State<CollectionManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Datos simulados de colecciones
  List<CollectionModel> collections = [
    CollectionModel(
      id: '1',
      name: 'Verano 2024',
      description: 'Colección fresca y colorida para el verano',
      season: 'Verano',
      year: 2024,
      isActive: true,
      productCount: 45,
      imageUrl: 'https://via.placeholder.com/300x200',
      colors: ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A'],
      tags: ['Casual', 'Playa', 'Colorido'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CollectionModel(
      id: '2',
      name: 'Otoño Elegante',
      description: 'Prendas sofisticadas para el otoño',
      season: 'Otoño',
      year: 2024,
      isActive: true,
      productCount: 32,
      imageUrl: 'https://via.placeholder.com/300x200',
      colors: ['#8B4513', '#D2691E', '#CD853F', '#A0522D'],
      tags: ['Elegante', 'Formal', 'Clásico'],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    CollectionModel(
      id: '3',
      name: 'Invierno Cozy',
      description: 'Abrigos y prendas cálidas',
      season: 'Invierno',
      year: 2023,
      isActive: false,
      productCount: 28,
      imageUrl: 'https://via.placeholder.com/300x200',
      colors: ['#2C3E50', '#34495E', '#7F8C8D', '#95A5A6'],
      tags: ['Abrigos', 'Cálido', 'Confort'],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
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
          'Gestión de Colecciones',
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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Activas'),
            Tab(text: 'Archivadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCollectionsList(collections),
          _buildCollectionsList(collections.where((c) => c.isActive).toList()),
          _buildCollectionsList(collections.where((c) => !c.isActive).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollectionDialog(),
        backgroundColor: const Color(0xFFEC4899),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Colección',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCollectionsList(List<CollectionModel> filteredCollections) {
    if (filteredCollections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay colecciones',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera colección para organizar tus productos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCollections.length,
      itemBuilder: (context, index) {
        final collection = filteredCollections[index];
        return _buildCollectionCard(collection);
      },
    );
  }

  Widget _buildCollectionCard(CollectionModel collection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la colección
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(collection.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            collection.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: collection.isActive
                                ? Colors.green
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            collection.isActive ? 'Activa' : 'Archivada',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      collection.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Información de la colección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estadísticas
                Row(
                  children: [
                    _buildStatItem(
                      Icons.inventory_2,
                      '${collection.productCount}',
                      'Productos',
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.calendar_today,
                      collection.season,
                      '${collection.year}',
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.access_time,
                      _formatDate(collection.createdAt),
                      'Creada',
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Paleta de colores
                Row(
                  children: [
                    const Text(
                      'Colores: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    ...collection.colors.map((color) => Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    )),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: collection.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEC4899).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFFEC4899),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editCollection(collection),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEC4899),
                          side: const BorderSide(color: Color(0xFFEC4899)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewProducts(collection),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Ver Productos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    if (difference < 30) return 'Hace ${difference}d';
    if (difference < 365) return 'Hace ${(difference / 30).round()}m';
    return 'Hace ${(difference / 365).round()}a';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Colecciones'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nombre de la colección...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implementar búsqueda
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Colecciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filtros por temporada, año, estado, etc.
            const Text('Filtros disponibles próximamente'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Colección'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre de la colección',
                hintText: 'Ej: Primavera 2024',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu colección...',
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
            onPressed: () {
              Navigator.pop(context);
              // Implementar creación de colección
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _editCollection(CollectionModel collection) {
    // Navegar a página de edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando colección: ${collection.name}'),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
  }

  void _viewProducts(CollectionModel collection) {
    // Navegar a productos de la colección
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viendo productos de: ${collection.name}'),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
  }
}

class CollectionModel {
  final String id;
  final String name;
  final String description;
  final String season;
  final int year;
  final bool isActive;
  final int productCount;
  final String imageUrl;
  final List<String> colors;
  final List<String> tags;
  final DateTime createdAt;

  CollectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.season,
    required this.year,
    required this.isActive,
    required this.productCount,
    required this.imageUrl,
    required this.colors,
    required this.tags,
    required this.createdAt,
  });
}