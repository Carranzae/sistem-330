import 'package:flutter/material.dart';

class VariantManagerPage extends StatefulWidget {
  const VariantManagerPage({super.key});

  @override
  State<VariantManagerPage> createState() => _VariantManagerPageState();
}

class _VariantManagerPageState extends State<VariantManagerPage> {
  final List<ProductVariant> _variants = [
    ProductVariant(
      id: '1',
      productName: 'Camiseta Básica',
      sku: 'CAM-001-M-AZ',
      size: 'M',
      color: 'Azul',
      material: 'Algodón',
      stock: 25,
      price: 29.99,
      isActive: true,
    ),
    ProductVariant(
      id: '2',
      productName: 'Camiseta Básica',
      sku: 'CAM-001-L-AZ',
      size: 'L',
      color: 'Azul',
      material: 'Algodón',
      stock: 15,
      price: 29.99,
      isActive: true,
    ),
    ProductVariant(
      id: '3',
      productName: 'Camiseta Básica',
      sku: 'CAM-001-M-RO',
      size: 'M',
      color: 'Rojo',
      material: 'Algodón',
      stock: 0,
      price: 29.99,
      isActive: false,
    ),
    ProductVariant(
      id: '4',
      productName: 'Zapatos Deportivos',
      sku: 'ZAP-002-42-NE',
      size: '42',
      color: 'Negro',
      material: 'Cuero sintético',
      stock: 8,
      price: 89.99,
      isActive: true,
    ),
    ProductVariant(
      id: '5',
      productName: 'Zapatos Deportivos',
      sku: 'ZAP-002-43-NE',
      size: '43',
      color: 'Negro',
      material: 'Cuero sintético',
      stock: 12,
      price: 89.99,
      isActive: true,
    ),
  ];

  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Variantes'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddVariantDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatsCards(),
            const SizedBox(height: 20),
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildVariantsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final activeVariants = _variants.where((v) => v.isActive).length;
    final totalStock = _variants.fold<int>(0, (sum, v) => sum + v.stock);
    final outOfStock = _variants.where((v) => v.stock == 0).length;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.inventory_2, size: 32, color: Colors.purple[600]),
                  const SizedBox(height: 8),
                  Text(
                    '${_variants.length}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Total Variantes'),
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
                    '$activeVariants',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  Icon(Icons.warning, size: 32, color: Colors.red[600]),
                  const SizedBox(height: 8),
                  Text(
                    '$outOfStock',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Sin Stock'),
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
                  Icon(Icons.storage, size: 32, color: Colors.blue[600]),
                  const SizedBox(height: 8),
                  Text(
                    '$totalStock',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Stock Total'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar variantes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: InputDecoration(
              labelText: 'Filtrar por',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Todos', child: Text('Todos')),
              DropdownMenuItem(value: 'Activas', child: Text('Activas')),
              DropdownMenuItem(value: 'Inactivas', child: Text('Inactivas')),
              DropdownMenuItem(value: 'Sin Stock', child: Text('Sin Stock')),
              DropdownMenuItem(value: 'Con Stock', child: Text('Con Stock')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsList() {
    final filteredVariants = _variants.where((variant) {
      final matchesSearch = variant.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          variant.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          variant.color.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          variant.size.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = switch (_selectedFilter) {
        'Activas' => variant.isActive,
        'Inactivas' => !variant.isActive,
        'Sin Stock' => variant.stock == 0,
        'Con Stock' => variant.stock > 0,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      itemCount: filteredVariants.length,
      itemBuilder: (context, index) {
        final variant = filteredVariants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(variant),
              child: Text(
                variant.size,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              variant.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${variant.sku}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip('Talla ${variant.size}', Colors.blue),
                    const SizedBox(width: 8),
                    _buildChip(variant.color, Colors.green),
                    const SizedBox(width: 8),
                    _buildChip('Stock: ${variant.stock}', variant.stock > 0 ? Colors.orange : Colors.red),
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
                  value: 'stock',
                  child: Row(
                    children: [
                      const Icon(Icons.inventory),
                      const SizedBox(width: 8),
                      const Text('Ajustar Stock'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(variant.isActive ? Icons.visibility_off : Icons.visibility),
                      const SizedBox(width: 8),
                      Text(variant.isActive ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleMenuAction(value, variant),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem('Material', variant.material),
                        ),
                        Expanded(
                          child: _buildDetailItem('Precio', '\$${variant.price.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem('Estado', variant.isActive ? 'Activa' : 'Inactiva'),
                        ),
                        Expanded(
                          child: _buildDetailItem('Stock Disponible', '${variant.stock} unidades'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Color _getStatusColor(ProductVariant variant) {
    if (!variant.isActive) return Colors.grey;
    if (variant.stock == 0) return Colors.red;
    if (variant.stock < 5) return Colors.orange;
    return Colors.green;
  }

  void _handleMenuAction(String action, ProductVariant variant) {
    switch (action) {
      case 'edit':
        _showEditVariantDialog(variant);
        break;
      case 'stock':
        _showStockAdjustmentDialog(variant);
        break;
      case 'toggle':
        setState(() {
          variant.isActive = !variant.isActive;
        });
        break;
      case 'delete':
        _showDeleteConfirmation(variant);
        break;
    }
  }

  void _showAddVariantDialog() {
    showDialog(
      context: context,
      builder: (context) => _VariantDialog(
        onSave: (variant) {
          setState(() {
            _variants.add(variant);
          });
        },
      ),
    );
  }

  void _showEditVariantDialog(ProductVariant variant) {
    showDialog(
      context: context,
      builder: (context) => _VariantDialog(
        variant: variant,
        onSave: (updatedVariant) {
          setState(() {
            final index = _variants.indexWhere((v) => v.id == variant.id);
            if (index != -1) {
              _variants[index] = updatedVariant;
            }
          });
        },
      ),
    );
  }

  void _showStockAdjustmentDialog(ProductVariant variant) {
    final controller = TextEditingController(text: variant.stock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Producto: ${variant.productName}'),
            Text('Variante: ${variant.size} - ${variant.color}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nuevo stock',
                border: OutlineInputBorder(),
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
            onPressed: () {
              final newStock = int.tryParse(controller.text) ?? 0;
              setState(() {
                variant.stock = newStock;
              });
              Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ProductVariant variant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la variante "${variant.sku}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _variants.removeWhere((v) => v.id == variant.id);
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

class _VariantDialog extends StatefulWidget {
  final ProductVariant? variant;
  final Function(ProductVariant) onSave;

  const _VariantDialog({
    this.variant,
    required this.onSave,
  });

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  late TextEditingController _productNameController;
  late TextEditingController _skuController;
  late TextEditingController _sizeController;
  late TextEditingController _colorController;
  late TextEditingController _materialController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.variant?.productName ?? '');
    _skuController = TextEditingController(text: widget.variant?.sku ?? '');
    _sizeController = TextEditingController(text: widget.variant?.size ?? '');
    _colorController = TextEditingController(text: widget.variant?.color ?? '');
    _materialController = TextEditingController(text: widget.variant?.material ?? '');
    _stockController = TextEditingController(text: widget.variant?.stock.toString() ?? '0');
    _priceController = TextEditingController(text: widget.variant?.price.toString() ?? '0.00');
    _isActive = widget.variant?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.variant == null ? 'Nueva Variante' : 'Editar Variante'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Talla',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _materialController,
              decoration: const InputDecoration(
                labelText: 'Material',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Variante activa'),
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
          onPressed: _saveVariant,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _saveVariant() {
    if (_productNameController.text.trim().isEmpty || _skuController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del producto y SKU son requeridos')),
      );
      return;
    }

    final variant = ProductVariant(
      id: widget.variant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      productName: _productNameController.text.trim(),
      sku: _skuController.text.trim(),
      size: _sizeController.text.trim(),
      color: _colorController.text.trim(),
      material: _materialController.text.trim(),
      stock: int.tryParse(_stockController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0.0,
      isActive: _isActive,
    );

    widget.onSave(variant);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _skuController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class ProductVariant {
  final String id;
  final String productName;
  final String sku;
  final String size;
  final String color;
  final String material;
  int stock;
  final double price;
  bool isActive;

  ProductVariant({
    required this.id,
    required this.productName,
    required this.sku,
    required this.size,
    required this.color,
    required this.material,
    required this.stock,
    required this.price,
    required this.isActive,
  });
}