import 'package:flutter/material.dart';

class CollectionManagerPage extends StatefulWidget {
  const CollectionManagerPage({super.key});

  @override
  State<CollectionManagerPage> createState() => _CollectionManagerPageState();
}

class _CollectionManagerPageState extends State<CollectionManagerPage> {
  final List<Collection> _collections = [
    Collection(
      id: '1',
      name: 'Verano 2024',
      description: 'Colección de verano con prendas frescas y coloridas',
      season: 'Verano',
      year: 2024,
      isActive: true,
      productCount: 45,
    ),
    Collection(
      id: '2',
      name: 'Invierno 2024',
      description: 'Colección de invierno con abrigos y prendas cálidas',
      season: 'Invierno',
      year: 2024,
      isActive: false,
      productCount: 32,
    ),
    Collection(
      id: '3',
      name: 'Primavera 2024',
      description: 'Colección primaveral con colores pastel',
      season: 'Primavera',
      year: 2024,
      isActive: true,
      productCount: 28,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Colecciones'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCollectionDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatsCards(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildCollectionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final activeCollections = _collections.where((c) => c.isActive).length;
    final totalProducts =
        _collections.fold<int>(0, (sum, c) => sum + c.productCount);

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.collections, size: 32, color: Colors.blue[600]),
                  const SizedBox(height: 8),
                  Text(
                    '${_collections.length}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Total Colecciones'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 32, color: Colors.green[600]),
                  const SizedBox(height: 8),
                  Text(
                    '$activeCollections',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Activas'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.inventory, size: 32, color: Colors.orange[600]),
                  const SizedBox(height: 8),
                  Text(
                    '$totalProducts',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Productos'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionsList() {
    return ListView.builder(
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        final collection = _collections[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: collection.isActive ? Colors.green : Colors.grey,
              child: Text(
                collection.season[0],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              collection.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${collection.productCount} productos'),
                    const SizedBox(width: 16),
                    Icon(
                      collection.isActive
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 16,
                      color: collection.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(collection.isActive ? 'Activa' : 'Inactiva'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      const Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(collection.isActive
                          ? Icons.visibility_off
                          : Icons.visibility),
                      const SizedBox(width: 8),
                      Text(collection.isActive ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Eliminar',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleMenuAction(value, collection),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, Collection collection) {
    switch (action) {
      case 'edit':
        _showEditCollectionDialog(collection);
        break;
      case 'toggle':
        setState(() {
          collection.isActive = !collection.isActive;
        });
        break;
      case 'delete':
        _showDeleteConfirmation(collection);
        break;
    }
  }

  void _showAddCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _CollectionDialog(
        onSave: (collection) {
          setState(() {
            _collections.add(collection);
          });
        },
      ),
    );
  }

  void _showEditCollectionDialog(Collection collection) {
    showDialog(
      context: context,
      builder: (context) => _CollectionDialog(
        collection: collection,
        onSave: (updatedCollection) {
          setState(() {
            final index = _collections.indexWhere((c) => c.id == collection.id);
            if (index != -1) {
              _collections[index] = updatedCollection;
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(Collection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar la colección "${collection.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _collections.removeWhere((c) => c.id == collection.id);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CollectionDialog extends StatefulWidget {
  final Collection? collection;
  final Function(Collection) onSave;

  const _CollectionDialog({
    this.collection,
    required this.onSave,
  });

  @override
  State<_CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<_CollectionDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedSeason;
  late int _selectedYear;
  late bool _isActive;

  final List<String> _seasons = ['Primavera', 'Verano', 'Otoño', 'Invierno'];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.collection?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.collection?.description ?? '');
    _selectedSeason = widget.collection?.season ?? 'Primavera';
    _selectedYear = widget.collection?.year ?? DateTime.now().year;
    _isActive = widget.collection?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.collection == null ? 'Nueva Colección' : 'Editar Colección'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la colección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Temporada',
                border: OutlineInputBorder(),
              ),
              items: _seasons.map((season) {
                return DropdownMenuItem(
                  value: season,
                  child: Text(season),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeason = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Año',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Colección activa'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCollection,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _saveCollection() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de la colección es requerido')),
      );
      return;
    }

    final collection = Collection(
      id: widget.collection?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      season: _selectedSeason,
      year: _selectedYear,
      isActive: _isActive,
      productCount: widget.collection?.productCount ?? 0,
    );

    widget.onSave(collection);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class Collection {
  final String id;
  final String name;
  final String description;
  final String season;
  final int year;
  bool isActive;
  final int productCount;

  Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.season,
    required this.year,
    required this.isActive,
    required this.productCount,
  });
}
