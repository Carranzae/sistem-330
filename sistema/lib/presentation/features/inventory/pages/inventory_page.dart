import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../widgets/product_qr_dialog.dart';
import '../widgets/qr_scanner_page.dart';
import 'add_product_page.dart';

/// Inventario Profesional con Gestión Completa
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'todos'; // todos, bajos, vencidos, activos
  String? _selectedCategory; // Para filtrar por categoría

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Aumentado a 6 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.hasBusiness) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MainLayout(
          businessCategory: provider.currentBusinessCategory,
          businessName: provider.currentBusinessName,
          child: _buildContent(provider.currentBusinessCategory),
        );
      },
    );
  }

  Widget _buildContent(String category) {
    return Column(
      children: [
        // Header con acciones principales
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventario',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildInventoryStats(),
                      ],
                    ),
                  ),
                  // Botón scanner QR
                  _buildActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Escanear',
                    color: const Color(0xFF2563EB),
                    onTap: () => _showQRScanner(context),
                  ),
                  const SizedBox(width: 8),
                  // Botón agregar producto
                  _buildActionButton(
                    icon: Icons.add_circle,
                    label: 'Agregar',
                    color: const Color(0xFF10B981),
                    onTap: () => _showAddProductDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Barra de búsqueda
              _buildSearchBar(),
              const SizedBox(height: 16),
              // Filtros rápidos
              _buildQuickFilters(),
            ],
          ),
        ),
        // Tabs de navegación
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFF59E0B),
            labelColor: const Color(0xFFF59E0B),
            unselectedLabelColor: const Color(0xFF6B7280),
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Entrada'),
              Tab(text: 'Salida'),
              Tab(text: 'Dashboard'),
              Tab(text: 'Historial'),
              Tab(text: 'Pronósticos'),
              Tab(text: 'Mi Score'),
            ],
          ),
        ),
        // Contenido de tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEntradaTab(),
              _buildSalidaTab(),
              _buildDashboardTab(),
              _buildHistorialTab(),
              _buildPronosticosTab(),
              _buildMyScoreTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryStats() {
    return Wrap(
      spacing: 24,
      children: [
        _buildStatItem('Total', '150 productos', const Color(0xFF2563EB)),
        _buildStatItem('En Stock', '142', const Color(0xFF10B981)),
        _buildStatItem('Bajo Stock', '8 alertas', const Color(0xFFF59E0B)),
        _buildStatItem('Sin Stock', '0', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, código o SKU...',
        prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() => _searchController.clear());
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildQuickFilters() {
    final filters = [
      {'label': 'Todos', 'value': 'todos', 'color': const Color(0xFF6B7280)},
      {'label': 'Stock Bajo', 'value': 'bajos', 'color': const Color(0xFFF59E0B)},
      {'label': 'Vencidos', 'value': 'vencidos', 'color': const Color(0xFFEF4444)},
      {'label': 'Sin Stock', 'value': 'sinstock', 'color': const Color(0xFF64748B)},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          
          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter['value'] as String);
              },
              backgroundColor: Colors.white,
              selectedColor: (filter['color'] as Color).withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? filter['color'] as Color : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? filter['color'] as Color : const Color(0xFFE5E7EB),
                width: isSelected ? 1.5 : 1,
              ),
              padding: EdgeInsets.zero,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsList({required bool filterStock}) {
    // Simular productos
    final products = _getSampleProducts(filterStock);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay productos ${filterStock ? 'con stock bajo' : ''}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega productos a tu inventario',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refrescar datos
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product, context);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    final hasLowStock = (product['stock_actual'] as num) <= (product['stock_minimo'] as num);
    final isOutOfStock = (product['stock_actual'] as num) == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : hasLowStock
                  ? const Color(0xFFF59E0B).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
          width: isOutOfStock || hasLowStock ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showProductDetails(product, context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen o placeholder
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product['imagen_url'] != null
                        ? Image.network(
                            product['imagen_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildProductIcon(),
                          )
                        : _buildProductIcon(),
                  ),
                ),
              const SizedBox(width: 16),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['nombre'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, size: 14, color: Color(0xFFF59E0B)),
                                SizedBox(width: 4),
                                Text(
                                  'Bajo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Agotado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['codigo'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${product['stock_actual']} / ${product['stock_minimo']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'S/ ${product['precio_venta'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón de acciones
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                onPressed: () => _showProductActions(product, context),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(
          Icons.inventory_2,
          size: 32,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildCategoriesView() {
    final categories = [
      {'name': 'Abarrotes', 'count': 45, 'color': const Color(0xFFF59E0B)},
      {'name': 'Lácteos', 'count': 23, 'color': const Color(0xFF3B82F6)},
      {'name': 'Bebidas', 'count': 30, 'color': const Color(0xFF10B981)},
      {'name': 'Limpieza', 'count': 18, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Congelados', 'count': 12, 'color': const Color(0xFF06B6D4)},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Filtrar por categoría
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category,
                    size: 32,
                    color: category['color'] as Color,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category['count']} productos',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleProducts(bool filterLowStock) {
    final allProducts = [
      {
        'id': '1',
        'nombre': 'Arroz Extra Superior 5kg',
        'codigo': 'PRD-001',
        'stock_actual': 15,
        'stock_minimo': 20,
        'precio_venta': 18.50,
        'categoria': 'Abarrotes',
        'imagen_url': null,
      },
      {
        'id': '2',
        'nombre': 'Aceite Vegetal 900ml',
        'codigo': 'PRD-002',
        'stock_actual': 8,
        'stock_minimo': 15,
        'precio_venta': 12.90,
        'categoria': 'Abarrotes',
        'imagen_url': null,
      },
      {
        'id': '3',
        'nombre': 'Leche Evaporada 400ml',
        'codigo': 'PRD-003',
        'stock_actual': 25,
        'stock_minimo': 10,
        'precio_venta': 3.50,
        'categoria': 'Lácteos',
        'imagen_url': null,
      },
    ];

    if (filterLowStock) {
      return allProducts.where((p) => (p['stock_actual'] as num) <= (p['stock_minimo'] as num)).toList();
    }

    return allProducts;
  }

  void _showProductDetails(Map<String, dynamic> product, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductDetailsSheet(product),
    );
  }

  Widget _buildProductDetailsSheet(Map<String, dynamic> product) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Título
                  const Text(
                    'Detalles del Producto',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Datos del producto
                  _buildDetailRow('Nombre', product['nombre']),
                  _buildDetailRow('Código', product['codigo']),
                  _buildDetailRow('Categoría', product['categoria']),
                  _buildDetailRow('Stock Actual', '${product['stock_actual']} unidades'),
                  _buildDetailRow('Stock Mínimo', '${product['stock_minimo']} unidades'),
                  _buildDetailRow('Precio Venta', 'S/ ${product['precio_venta'].toStringAsFixed(2)}'),
                  const SizedBox(height: 32),
                  // Acciones
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAdjustStock(product);
                      },
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Ajustar Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showProductQR(context, product);
                          },
                          icon: const Icon(Icons.qr_code_2),
                          label: const Text('Generar QR'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _editProduct(context, product);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onQRScanned: (data) {
            // Procesar QR escaneado
            _handleQRScanned(data);
          },
        ),
      ),
    );
  }
  
  void _handleQRScanned(Map<String, dynamic> data) {
    if (data['type'] == 'product') {
      // Mostrar detalles del producto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto encontrado: ${data['productId']}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else if (data['tipo'] == 'venta') {
      // Registrar venta desde QR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venta registrada: ${data['productoNombre']}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else if (data['tipo'] == 'entrada') {
      // Registrar entrada desde QR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada registrada: ${data['cantidad']} unidades'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showAddProductDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductPage(),
      ),
    );
  }

  void _showProductActions(Map<String, dynamic> product, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Color(0xFF2563EB)),
              title: const Text('Ajustar Stock'),
              onTap: () {
                Navigator.pop(context);
                _showAdjustStock(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: Color(0xFF10B981)),
              title: const Text('Generar Código QR'),
              onTap: () {
                Navigator.pop(context);
                _showProductQR(context, product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFF59E0B)),
              title: const Text('Editar Producto'),
              onTap: () {
                Navigator.pop(context);
                _editProduct(context, product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Eliminar
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStock(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Stock'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Formulario para aumentar o disminuir stock'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showProductQR(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => ProductQRDialog(
        productId: product['id'] ?? '',
        productName: product['nombre'] ?? '',
        productCode: product['codigo'] ?? '',
        price: (product['precio_venta'] as num).toDouble(),
      ),
    );
  }

  void _editProduct(BuildContext context, Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(product: product),
      ),
    );
  }

  // Nuevas pestañas implementadas
  Widget _buildEntradaTab() {
    final categories = ['Abarrotes', 'Lácteos', 'Bebidas', 'Limpieza', 'Aseo Personal', 'Otros'];
    
    if (_selectedCategory == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona una categoría',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Abre la tabla de productos de la categoría',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón escanear
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _scanWithScanner(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Escanear con Pistola',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCardForEntry(categories[index]);
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // Mostrar tabla de productos de esa categoría
      return _buildProductsTable(_selectedCategory!);
    }
  }

  Widget _buildCategoryCardForEntry(String category) {
    final colors = {
      'Abarrotes': Colors.amber,
      'Lácteos': Colors.blue,
      'Bebidas': Colors.green,
      'Limpieza': Colors.purple,
      'Aseo Personal': Colors.cyan,
      'Otros': Colors.grey,
    };
    
    final color = colors[category] ?? Colors.grey;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.category, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTable(String category) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de tabla con acciones
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedCategory = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categoría: $category',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Text(
                      'Gestión de productos de entrada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Botones de acción
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _addProductToCategory(category),
                tooltip: 'Agregar Producto',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _exportTableToExcel(category),
                tooltip: 'Exportar a Excel',
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => _exportTableToPDF(category),
                tooltip: 'Exportar a PDF',
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Resumen de inversión
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      'Total Invertido',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/ 45,230.00',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Valor de Venta',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/ 68,450.00',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tabla de productos
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                  columns: const [
                    DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Fecha Ingreso', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('P. Compra', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('P. Venta', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('QR', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                  rows: _getProductsForCategory(category).map((product) {
                    return DataRow(
                      cells: [
                        DataCell(Text(product['id'] ?? '')),
                        DataCell(Text(product['nombre'] ?? '')),
                        DataCell(Text(product['tipo'] ?? '')),
                        DataCell(Text(product['fecha_ingreso'] ?? '')),
                        DataCell(Text('${product['cantidad'] ?? 0}')),
                        DataCell(Text('S/ ${(product['precio_compra'] ?? 0.0).toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${(product['precio_venta'] ?? 0.0).toStringAsFixed(2)}')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.qr_code, size: 20),
                            onPressed: () => _showProductQR(context, product),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _editProduct(context, product),
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () => _deleteProduct(product),
                                tooltip: 'Eliminar',
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getProductsForCategory(String category) {
    // Simular productos según categoría
    switch (category) {
      case 'Lácteos':
        return [
          {
            'id': 'LAC-001',
            'nombre': 'Leche Evaporada',
            'tipo': '400ml',
            'fecha_ingreso': '15/01/2024',
            'cantidad': 250,
            'precio_compra': 2.50,
            'precio_venta': 3.50,
          },
          {
            'id': 'LAC-002',
            'nombre': 'Yogurt',
            'tipo': '1kg',
            'fecha_ingreso': '14/01/2024',
            'cantidad': 180,
            'precio_compra': 3.20,
            'precio_venta': 4.50,
          },
        ];
      case 'Abarrotes':
        return [
          {
            'id': 'ABR-001',
            'nombre': 'Arroz Extra Superior',
            'tipo': '5kg',
            'fecha_ingreso': '10/01/2024',
            'cantidad': 150,
            'precio_compra': 15.00,
            'precio_venta': 18.50,
          },
          {
            'id': 'ABR-002',
            'nombre': 'Aceite Vegetal',
            'tipo': '900ml',
            'fecha_ingreso': '12/01/2024',
            'cantidad': 120,
            'precio_compra': 10.00,
            'precio_venta': 12.90,
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildSalidaTab() {
    final categories = ['Abarrotes', 'Lácteos', 'Bebidas', 'Limpieza', 'Aseo Personal', 'Otros'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registro de Ventas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Productos vendidos por categoría',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Resumen de ventas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Vendido Hoy'),
                    Text(
                      'S/ 1,245.50',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Unidades Vendidas', style: TextStyle(color: Colors.green.shade700)),
                    Text('156', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.green.shade900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ventas por Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          // Grid de categorías
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildSalesCategoryCard(categories[index]);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesCategoryCard(String category) {
    final colors = {
      'Abarrotes': Colors.amber,
      'Lácteos': Colors.blue,
      'Bebidas': Colors.green,
      'Limpieza': Colors.purple,
      'Aseo Personal': Colors.cyan,
      'Otros': Colors.grey,
    };
    
    final color = colors[category] ?? Colors.grey;
    final salesCount = (category.hashCode % 50) + 20; // Simulación
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.category, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  '$salesCount ventas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard de Inventario',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vista general por categorías',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Métricas generales
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.inventory_2, color: Colors.blue.shade700, size: 24),
                      const SizedBox(height: 12),
                      const Text('Stock Total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '2,450',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                      const SizedBox(height: 12),
                      const Text('Activos', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '98%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráfico por categorías
          const Text(
            'Distribución por Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoriesView(),
        ],
      ),
    );
  }

  Widget _buildHistorialTab() {
    final movements = [
      {
        'type': 'entrada',
        'product': 'Arroz Extra 5kg',
        'quantity': 150,
        'date': '15/01/2024 10:30',
        'user': 'Admin',
      },
      {
        'type': 'salida',
        'product': 'Aceite Vegetal 900ml',
        'quantity': 25,
        'date': '15/01/2024 11:00',
        'user': 'Admin',
      },
      {
        'type': 'entrada',
        'product': 'Leche Evaporada',
        'quantity': 250,
        'date': '14/01/2024 09:15',
        'user': 'Admin',
      },
      {
        'type': 'salida',
        'product': 'Azúcar Rubia',
        'quantity': 40,
        'date': '14/01/2024 14:20',
        'user': 'Admin',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Historial de Movimientos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filtrar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Lista de movimientos
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.length,
            itemBuilder: (context, index) {
              return _buildMovementCard(movements[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMovementCard(Map<String, dynamic> movement) {
    final isEntry = movement['type'] == 'entrada';
    final color = isEntry ? Colors.blue : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEntry ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement['product'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      movement['date'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEntry ? '+' : '-'}${movement['quantity']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                movement['user'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPronosticosTab() {
    final topProducts = [
      {'name': 'Arroz Extra 5kg', 'sales': 45, 'trend': 'up'},
      {'name': 'Aceite Vegetal', 'sales': 38, 'trend': 'up'},
      {'name': 'Azúcar Rubia', 'sales': 32, 'trend': 'stable'},
      {'name': 'Leche Evaporada', 'sales': 28, 'trend': 'up'},
    ];

    final recommendations = [
      {'product': 'Fideos Tallarín', 'reason': 'Alta rotación esperada', 'suggested': 120},
      {'product': 'Aceite Vegetal', 'reason': 'Stock bajo', 'suggested': 150},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronósticos de Venta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Análisis de ventas y recomendaciones',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Productos más vendidos
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Productos Más Vendidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...topProducts.map((product) {
                  final trend = product['trend'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['name'] as String,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '${product['sales']} ventas',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          trend == 'up'
                              ? Icons.arrow_upward
                              : trend == 'down'
                                  ? Icons.arrow_downward
                                  : Icons.remove,
                          size: 18,
                          color: trend == 'up'
                              ? Colors.green
                              : trend == 'down'
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recomendaciones
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Recomendaciones de Compra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...recommendations.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['product'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec['reason'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.shopping_cart, size: 16, color: Colors.orange.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Sugerencia: ${rec['suggested']} unidades',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyScoreTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 80, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            'Mi Score de Ingresos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  void _scanWithScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escaneando con pistola láser...')),
    );
  }

  void _addProductToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(),
      ),
    );
  }

  void _exportTableToExcel(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exportando $category a Excel...')),
    );
  }

  void _exportTableToPDF(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exportando $category a PDF...')),
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Confirmar eliminación de ${product['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
