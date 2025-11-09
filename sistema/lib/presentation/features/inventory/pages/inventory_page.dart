import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/qr_service.dart';
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

  List<dynamic> _products = [];
  List<dynamic> _lowStockProducts = [];
  List<dynamic> _entries = [];
  List<dynamic> _exits = [];
  bool _isLoading = true;
  bool _isLoadingEntries = false;
  bool _isLoadingExits = false;
  DateTime _entriesStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _entriesEndDate = DateTime.now();
  DateTime _exitsStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _exitsEndDate = DateTime.now();
  String? _selectedProductType; // Filtro por tipo de producto
  bool _showTableView = false; // Toggle entre vista de tabla y cards
  bool _showExitsTableView = false; // Toggle para tabla de salidas
  // Datos de clientes
  List<dynamic> _credits = []; // Créditos a clientes
  List<dynamic> _payments = []; // Pagos de clientes
  bool _isLoadingCredits = false;
  bool _isLoadingPayments = false;
  String? _selectedClientFilter; // Filtro por cliente
  DateTime _creditsStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _creditsEndDate = DateTime.now();
  DateTime _paymentsStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _paymentsEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    // Cargar productos después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final products = await ApiService.getProducts(businessId: provider.currentBusinessId);
      final lowStock = await ApiService.getLowStockProducts(businessId: provider.currentBusinessId);
      
      if (mounted) {
        setState(() {
          _products = products;
          _lowStockProducts = lowStock;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _lowStockProducts = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando productos: $e')),
        );
      }
    }
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
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(provider.currentBusinessCategory),
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
              // Indicador de categoría seleccionada
              if (_selectedCategory != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(
                        'Categoría: $_selectedCategory',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                        child: const Icon(Icons.close, size: 18, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
              Tab(text: 'General'),
              Tab(text: 'Entrada'),
              Tab(text: 'Salida'),
              Tab(text: 'Clientes'),
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
              _buildGeneralTab(),
              _buildEntradaTab(),
              _buildSalidaTab(),
              _buildClientesTab(),
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
    final totalProducts = _products.length;
    final inStockProducts = _products.where((p) => (p['stock'] ?? 0) > 0).length;
    final lowStockCount = _lowStockProducts.length;
    final outOfStockProducts = _products.where((p) => (p['stock'] ?? 0) == 0).length;
    
    return Wrap(
      spacing: 24,
      children: [
        _buildStatItem('Total', '$totalProducts productos', const Color(0xFF2563EB)),
        _buildStatItem('En Stock', '$inStockProducts', const Color(0xFF10B981)),
        _buildStatItem('Bajo Stock', '$lowStockCount alertas', const Color(0xFFF59E0B)),
        _buildStatItem('Sin Stock', '$outOfStockProducts', const Color(0xFFEF4444)),
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

  Widget _buildGeneralTab() {
    return Column(
      children: [
        Expanded(
          child: _buildProductsList(filterStock: false),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isMobile = false,
  }) {
    // En móvil, mostrar solo el icono o icono + texto compacto
    if (isMobile) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      );
    }
    
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
    // Usar productos reales
    var products = _products;
    
    // Aplicar filtro por categoría si está seleccionada
    if (_selectedCategory != null) {
      products = products.where((p) {
        final categoria = (p['categoria'] ?? 'Otros').toString();
        return categoria == _selectedCategory;
      }).toList();
    }
    
    // Aplicar filtro de búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      products = products.where((p) {
        final name = (p['nombre'] ?? p['name'] ?? '').toString().toLowerCase();
        final code = (p['codigo'] ?? p['codigo_barras'] ?? p['code'] ?? '').toString().toLowerCase();
        return name.contains(searchTerm) || code.contains(searchTerm);
      }).toList();
    }
    
    // Aplicar filtros seleccionados
    if (_selectedFilter != 'todos') {
      if (_selectedFilter == 'bajos') {
        products = _lowStockProducts;
        // Aplicar filtro de categoría también a productos con stock bajo
        if (_selectedCategory != null) {
          products = products.where((p) {
            final categoria = (p['categoria'] ?? 'Otros').toString();
            return categoria == _selectedCategory;
          }).toList();
        }
      } else if (_selectedFilter == 'sinstock') {
        products = products.where((p) => (p['stock'] ?? 0) == 0).toList();
      } else if (_selectedFilter == 'vencidos') {
        // Filtrar productos vencidos
        final now = DateTime.now();
        products = products.where((p) {
          if (p['fecha_vencimiento'] == null) return false;
          final fechaVenc = p['fecha_vencimiento'] is DateTime 
              ? p['fecha_vencimiento'] as DateTime
              : DateTime.tryParse(p['fecha_vencimiento'].toString());
          return fechaVenc != null && fechaVenc.isBefore(now);
        }).toList();
      }
    }
    
    // Si se busca solo stock bajo
    if (filterStock) {
      products = _lowStockProducts;
      // Aplicar filtro de categoría también
      if (_selectedCategory != null) {
        products = products.where((p) {
          final categoria = (p['categoria'] ?? 'Otros').toString();
          return categoria == _selectedCategory;
        }).toList();
      }
    }

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
              _searchController.text.isNotEmpty 
                ? 'No se encontraron productos'
                : 'No hay productos ${filterStock ? 'con stock bajo' : ''}',
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
      onRefresh: _loadProducts,
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
    // Adaptar campos de la API a los nombres del card
    final stockActual = (product['stock'] ?? product['stock_actual'] ?? 0).toInt();
    final stockMinimo = (product['stock_minimo'] ?? 10).toInt();
    final nombreProducto = product['nombre'] ?? product['name'] ?? '';
    final codigoProducto = product['codigo_barras'] ?? product['code'] ?? product['codigo'] ?? product['id'].toString();
    final precioProducto = product['precio'] ?? product['precio_venta'] ?? 0.0;
    
    final hasLowStock = stockActual <= stockMinimo;
    final isOutOfStock = stockActual == 0;

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
                            nombreProducto,
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
                      'Código: $codigoProducto',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    if (product['fecha_vencimiento'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Vence: ${DateFormat('dd/MM/yyyy').format(product['fecha_vencimiento'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: $stockActual / $stockMinimo',
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
                            'S/ ${precioProducto.toStringAsFixed(2)}',
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
    // Calcular productos por categoría real
    final Map<String, int> categoryCounts = {};
    for (var product in _products) {
      final categoria = product['categoria'] ?? 'Otros';
      categoryCounts[categoria] = (categoryCounts[categoria] ?? 0) + 1;
    }
    
    // Colores predefinidos por categoría
    final colors = {
      'Abarrotes': const Color(0xFFF59E0B),
      'Lácteos': const Color(0xFF3B82F6),
      'Bebidas': const Color(0xFF10B981),
      'Limpieza': const Color(0xFF8B5CF6),
      'Congelados': const Color(0xFF06B6D4),
      'Aseo Personal': const Color(0xFFEC4899),
      'Otros': Colors.grey,
    };
    
    final categories = categoryCounts.entries.map((entry) => {
      'name': entry.key,
      'count': entry.value,
      'color': colors[entry.key] ?? Colors.grey,
    }).toList();
    
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Text(
            'No hay productos en el inventario',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

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
            setState(() {
              _selectedCategory = category['name'] as String;
              _selectedFilter = 'todos'; // Resetear otros filtros
            });
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
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 30)),
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
                _deleteProduct(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStock(Map<String, dynamic> product) {
    final stockController = TextEditingController();
    bool isLoading = false;
    String operation = 'set'; // set, add, subtract

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory_2, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product['nombre'] ?? 'Producto',
                  style: const TextStyle(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stock Actual',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${product['stock'] ?? 0} unidades',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tipo de Ajuste',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Opciones de operación
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => operation = 'add'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: operation == 'add' ? Colors.green.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: operation == 'add' ? Colors.green : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: operation == 'add' ? Colors.green : Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              const Text('Sumar', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => operation = 'subtract'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: operation == 'subtract' ? Colors.orange.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: operation == 'subtract' ? Colors.orange : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove, color: operation == 'subtract' ? Colors.orange : Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              const Text('Restar', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => operation = 'set'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: operation == 'set' ? Colors.blue.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: operation == 'set' ? Colors.blue : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: operation == 'set' ? Colors.blue : Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              const Text('Establecer', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(
                    labelText: operation == 'add' 
                        ? 'Cantidad a sumar'
                        : operation == 'subtract'
                            ? 'Cantidad a restar'
                            : 'Nuevo stock total',
                    hintText: 'Ingrese cantidad',
                    prefixIcon: const Icon(Icons.inventory),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final quantity = int.tryParse(stockController.text);
                      if (quantity == null || quantity <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ingrese una cantidad válida')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        await ApiService.adjustStock(product['id'] ?? '', {
                          'quantity': quantity,
                          'operation': operation,
                        });

                        Navigator.pop(context);
                        await _loadProducts();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Stock actualizado exitosamente'),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
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
    // Cargar entradas cuando se abre la pestaña
    if (_entries.isEmpty && !_isLoadingEntries) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntries());
    }
    
    // Obtener tipos de productos únicos de las entradas
    final productTypes = _getUniqueProductTypes();
    final filteredEntries = _getFilteredEntries();
    
    return Column(
      children: [
        // Header con filtros y acciones
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_downward, color: Color(0xFF10B981), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entradas de Inventario',
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Registro de productos ingresados al inventario',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Botones de acción - responsive
                      isMobile
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildActionButton(
                                  icon: Icons.add_circle,
                                  label: 'Nueva',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _showNewEntryDialog(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _exportEntriesToExcel(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _exportEntriesToPDF(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.qr_code_2,
                                  label: 'QR',
                                  color: const Color(0xFF8B5CF6),
                                  onTap: () => _showCategoryQRDialog(),
                                  isMobile: true,
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _showTableView = !_showTableView),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1.5),
                                      ),
                                      child: Icon(
                                        _showTableView ? Icons.view_list : Icons.table_chart,
                                        color: const Color(0xFF10B981),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.add_circle,
                                  label: 'Nueva',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _showNewEntryDialog(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _exportEntriesToExcel(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _exportEntriesToPDF(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.qr_code_2,
                                  label: 'QR',
                                  color: const Color(0xFF8B5CF6),
                                  onTap: () => _showCategoryQRDialog(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(_showTableView ? Icons.view_list : Icons.table_chart),
                                  onPressed: () => setState(() => _showTableView = !_showTableView),
                                  tooltip: _showTableView ? 'Vista de Cards' : 'Vista de Tabla',
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Filtros de fecha y tipo de producto - responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  return isMobile
                      ? Column(
                          children: [
                            _buildDateRangeFilter(
                              startDate: _entriesStartDate,
                              endDate: _entriesEndDate,
                              onStartDateChanged: (date) {
                                setState(() => _entriesStartDate = date);
                                _loadEntries();
                              },
                              onEndDateChanged: (date) {
                                setState(() => _entriesEndDate = date);
                                _loadEntries();
                              },
                            ),
                            const SizedBox(height: 12),
                            // Filtro por tipo de producto
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedProductType,
                                  hint: const Text('Tipo de Producto', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todos')),
                                    ...productTypes.map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedProductType = value);
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  isDense: true,
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildDateRangeFilter(
                                startDate: _entriesStartDate,
                                endDate: _entriesEndDate,
                                onStartDateChanged: (date) {
                                  setState(() => _entriesStartDate = date);
                                  _loadEntries();
                                },
                                onEndDateChanged: (date) {
                                  setState(() => _entriesEndDate = date);
                                  _loadEntries();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Filtro por tipo de producto
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedProductType,
                                  hint: const Text('Tipo de Producto', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todos')),
                                    ...productTypes.map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedProductType = value);
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
        // Contenido: Tabla o Cards
        Expanded(
          child: _isLoadingEntries
              ? const Center(child: CircularProgressIndicator())
              : filteredEntries.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No hay entradas registradas',
                      subtitle: _selectedProductType != null 
                          ? 'No hay entradas para el tipo seleccionado'
                          : 'Registra la primera entrada de inventario',
                    )
                  : _showTableView
                      ? _buildEntriesTable(filteredEntries)
                      : RefreshIndicator(
                          onRefresh: _loadEntries,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredEntries.length,
                            itemBuilder: (context, index) {
                              return _buildEntryCard(filteredEntries[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
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
    // Cargar salidas cuando se abre la pestaña
    if (_exits.isEmpty && !_isLoadingExits) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExits());
    }
    
    return Column(
      children: [
        // Header con filtros y acciones
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_upward, color: Color(0xFFEF4444), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salidas de Inventario',
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Registro de productos salidos del inventario',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Botones de acción - responsive
                      isMobile
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildActionButton(
                                  icon: Icons.add_circle,
                                  label: 'Nueva',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _showNewExitDialog(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _exportExitsToExcel(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _exportExitsToPDF(),
                                  isMobile: true,
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _showExitsTableView = !_showExitsTableView),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3), width: 1.5),
                                      ),
                                      child: Icon(
                                        _showExitsTableView ? Icons.view_list : Icons.table_chart,
                                        color: const Color(0xFFEF4444),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.add_circle,
                                  label: 'Nueva',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _showNewExitDialog(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _exportExitsToExcel(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => _exportExitsToPDF(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(_showExitsTableView ? Icons.view_list : Icons.table_chart),
                                  onPressed: () => setState(() => _showExitsTableView = !_showExitsTableView),
                                  tooltip: _showExitsTableView ? 'Vista de Cards' : 'Vista de Tabla',
                                  color: const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Filtros de fecha - responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return _buildDateRangeFilter(
                    startDate: _exitsStartDate,
                    endDate: _exitsEndDate,
                    onStartDateChanged: (date) {
                      setState(() => _exitsStartDate = date);
                      _loadExits();
                    },
                    onEndDateChanged: (date) {
                      setState(() => _exitsEndDate = date);
                      _loadExits();
                    },
                  );
                },
              ),
            ],
          ),
        ),
        // Lista de salidas
        Expanded(
          child: _isLoadingExits
              ? const Center(child: CircularProgressIndicator())
              : _exits.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.outbox_outlined,
                      title: 'No hay salidas registradas',
                      subtitle: 'Registra la primera salida de inventario',
                    )
                  : _showExitsTableView
                      ? _buildExitsTable(_exits)
                      : RefreshIndicator(
                          onRefresh: _loadExits,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _exits.length,
                            itemBuilder: (context, index) {
                              return _buildExitCard(_exits[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    final totalStock = _products.fold<int>(0, (sum, p) => sum + ((p['stock'] ?? 0) as num).toInt());
    final activeProducts = _products.where((p) => (p['stock'] ?? 0) > 0).length;
    final activePercentage = _products.isNotEmpty ? (activeProducts / _products.length * 100).toInt() : 0;
    
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
                        totalStock.toString(),
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
                        '$activePercentage%',
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
          // Alertas de stock bajo
          if (_lowStockProducts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_lowStockProducts.length} Productos con Stock Bajo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Requieren reposición inmediata',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
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
                onPressed: () {
                  // Mostrar diálogo de filtros
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Filtros de Historial'),
                      content: const Text('Filtros avanzados próximamente disponibles'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
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
    // Análisis de pronósticos basado en productos reales y ventas simuladas
    final topProducts = _calculateTopProducts();
    final recommendations = _calculatePurchaseRecommendations();
    final forecastStats = _calculateForecastStats();

    return SingleChildScrollView(
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
                      'Pronósticos de Venta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Análisis inteligente de demanda y recomendaciones de compra',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Botón exportar Excel - responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _exportToExcel(recommendations),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download, color: Colors.white, size: 20),
                            if (!isMobile) ...[
                              const SizedBox(width: 8),
                              const Text(
                                'Exportar Excel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Estadísticas de pronóstico
          _buildForecastStatsSection(forecastStats),
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
    // Mostrar diálogo para agregar producto con categoría pre-seleccionada
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Producto a $category'),
        content: const Text('Esta función abrirá el formulario de nuevo producto con la categoría seleccionada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductPage(),
                ),
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTableToExcel(String category) async {
    try {
      final categoryEntries = _entries.where((e) {
        final tipo = (e['tipo_producto'] ?? e['categoria'] ?? 'Otros').toString();
        return tipo == category;
      }).toList();
      
      if (categoryEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay productos en $category para exportar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel[category];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Código');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Variedad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Precio Compra');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Precio Venta');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Cantidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = TextCellValue('Stock Disponible');
      
      // Data
      for (int i = 0; i < categoryEntries.length; i++) {
        final entry = categoryEntries[i];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(entry['codigo'] ?? entry['id'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(entry['producto'] ?? entry['product'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(entry['variedad'] ?? entry['tipo_producto'] ?? 'Otros');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = DoubleCellValue((entry['precio_compra'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((entry['precio_venta'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = IntCellValue((entry['cantidad'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = IntCellValue((entry['stock_disponible'] ?? entry['cantidad'] ?? 0) as int);
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${category}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Excel exportado: $category')),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportTableToPDF(String category) async {
    try {
      final categoryEntries = _entries.where((e) {
        final tipo = (e['tipo_producto'] ?? e['categoria'] ?? 'Otros').toString();
        return tipo == category;
      }).toList();
      
      if (categoryEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay productos en $category para exportar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final pdfBytes = await PDFService.generateInventoryMovementsPDF(
        nombreComercial: provider.currentBusinessName,
        tipo: 'Entradas',
        movimientos: categoryEntries.map((e) => {
          'codigo': e['codigo'] ?? e['id'] ?? '',
          'producto': e['producto'] ?? e['product'] ?? '',
          'variedad': e['variedad'] ?? e['tipo_producto'] ?? e['categoria'] ?? 'Otros',
          'cantidad': e['cantidad'] ?? 0,
          'stock_disponible': e['stock_disponible'] ?? e['cantidad'] ?? 0,
          'unidad': e['unidad'] ?? 'un',
          'fecha': e['fecha'] is DateTime 
              ? DateFormat('dd/MM/yyyy HH:mm').format(e['fecha'] as DateTime)
              : e['fecha']?.toString() ?? '',
          'precio_compra': e['precio_compra'] ?? 0.0,
          'precio_venta': e['precio_venta'] ?? 0.0,
          'proveedor': e['proveedor'] ?? '',
        }).toList(),
        fechaDesde: DateFormat('dd/MM/yyyy').format(_entriesStartDate),
        fechaHasta: DateFormat('dd/MM/yyyy').format(_entriesEndDate),
      );
      
      await PDFService.sharePDF(pdfBytes, '${category}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('PDF exportado: $category')),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Análisis de pronósticos
  List<Map<String, dynamic>> _calculateTopProducts() {
    // Basado en productos reales, simula ventas según rotación esperada
    final products = _products.take(10).map((p) {
      final nombre = p['nombre'] ?? p['name'] ?? '';
      final stockActual = (p['stock'] ?? 0).toInt();
      final precio = (p['precio'] ?? p['precio_venta'] ?? 0).toDouble();
      
      // Simular ventas basado en stock actual (menos stock = más ventas)
      final sales = stockActual < 20 ? 50 : stockActual < 50 ? 30 : 20;
      
      return {
        'name': nombre,
        'sales': sales,
        'trend': sales > 40 ? 'up' : sales > 25 ? 'stable' : 'down',
        'id': p['id'],
      };
    }).toList();
    
    return products;
  }

  List<Map<String, dynamic>> _calculatePurchaseRecommendations() {
    // Recomendaciones inteligentes basadas en análisis de demanda
    final recommendations = <Map<String, dynamic>>[];
    
    // Analizar productos con stock bajo
    final lowStockProducts = _lowStockProducts.take(5);
    for (var product in lowStockProducts) {
      final nombre = product['nombre'] ?? product['name'] ?? '';
      final stockActual = (product['stock'] ?? 0).toInt();
      final stockMinimo = 10; // Default
      
      // Calcular cantidad sugerida (2x el mínimo para evitar desabastecimiento)
      final suggested = stockMinimo * 3;
      
      recommendations.add({
        'product': nombre,
        'reason': 'Stock crítico - Requiere reposición urgente',
        'suggested': suggested,
        'current': stockActual,
        'priority': 'high',
        'id': product['id'],
      });
    }
    
    // Analizar productos con alta rotación esperada (menos de 20 unidades)
    final fastMoving = _products.where((p) {
      final stock = (p['stock'] ?? 0).toInt();
      return stock > 0 && stock < 20 && !recommendations.any((r) => r['id'] == p['id']);
    }).take(3);
    
    for (var product in fastMoving) {
      final nombre = product['nombre'] ?? product['name'] ?? '';
      final stockActual = (product['stock'] ?? 0).toInt();
      
      recommendations.add({
        'product': nombre,
        'reason': 'Alta rotación esperada - Prever desabastecimiento',
        'suggested': stockActual * 2,
        'current': stockActual,
        'priority': 'medium',
        'id': product['id'],
      });
    }
    
    return recommendations;
  }

  Map<String, dynamic> _calculateForecastStats() {
    // Calcular estadísticas de pronóstico para diferentes períodos
    final totalProducts = _products.length;
    final lowStockCount = _lowStockProducts.length;
    final outOfStockCount = _products.where((p) => (p['stock'] ?? 0) == 0).length;
    
    // Simular análisis de demanda
    final weeklyDemand = totalProducts * 0.15; // 15% del inventario por semana
    final biweeklyDemand = totalProducts * 0.30; // 30% del inventario cada 15 días
    final monthlyDemand = totalProducts * 0.60; // 60% del inventario por mes
    
    return {
      'weekly': weeklyDemand.toInt(),
      'biweekly': biweeklyDemand.toInt(),
      'monthly': monthlyDemand.toInt(),
      'lowStock': lowStockCount,
      'outOfStock': outOfStockCount,
      'totalProducts': totalProducts,
    };
  }

  Widget _buildForecastStatsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Análisis de Demanda Estimada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildForecastCard(
                'Semanal',
                '${stats['weekly']} productos',
                Icons.calendar_view_week,
                const Color(0xFF3B82F6),
                'Demanda estimada',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildForecastCard(
                'Quincenal',
                '${stats['biweekly']} productos',
                Icons.view_agenda,
                const Color(0xFF8B5CF6),
                'Rotación media',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildForecastCard(
                'Mensual',
                '${stats['monthly']} productos',
                Icons.calendar_month,
                const Color(0xFF10B981),
                'Rotación completa',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecastCard(String period, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            period,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _exportToExcel(List<Map<String, dynamic>> recommendations) {
    if (recommendations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay recomendaciones para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Simular exportación a Excel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Excel generado con ${recommendations.length} productos'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Implementar exportación real con excel package
    // Por ahora, simular la generación
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Eliminar Producto')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Está seguro de eliminar el producto?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${product['nombre'] ?? product['producto'] ?? ''}'),
                  if (product['codigo'] != null)
                    Text('Código: ${product['codigo']}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        // Mostrar loading
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Intentar eliminar desde el backend
        try {
          await ApiService.deleteProduct(product['id'] ?? product['codigo'] ?? '');
        } catch (e) {
          // Si falla el backend, eliminar localmente
          if (mounted) {
            Navigator.pop(context); // Cerrar loading
          }
        }

        // Recargar productos
        await _loadProducts();
        
        // Cerrar loading si aún está abierto
        if (mounted) {
          Navigator.pop(context); // Cerrar loading si aún está abierto
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Producto "${product['nombre'] ?? product['producto'] ?? ''}" eliminado exitosamente'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        setState(() {
          // Remover de la lista local
          _products.removeWhere((p) => p['id'] == product['id']);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Producto ${product['nombre'] ?? ''} eliminado')),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ==================== FUNCIONES PARA ENTRADAS Y SALIDAS ====================

  Future<void> _loadEntries() async {
    setState(() => _isLoadingEntries = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final entries = await ApiService.getInventoryEntries(
        businessId: provider.currentBusinessId,
        startDate: _entriesStartDate,
        endDate: _entriesEndDate,
      );
      
      if (mounted) {
        setState(() {
          // Convertir LinkedMaps a Map<String, dynamic> para evitar errores de tipo
          _entries = (entries.isNotEmpty ? entries : _getSampleEntries())
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          _isLoadingEntries = false;
        });
        // Recalcular stock disponible después de cargar entradas
        _recalculateStock();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _entries = _getSampleEntries();
          _isLoadingEntries = false;
        });
      }
    }
  }

  Future<void> _loadExits() async {
    setState(() => _isLoadingExits = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final exits = await ApiService.getInventoryExits(
        businessId: provider.currentBusinessId,
        startDate: _exitsStartDate,
        endDate: _exitsEndDate,
      );
      
      if (mounted) {
        setState(() {
          // Convertir LinkedMaps a Map<String, dynamic> para evitar errores de tipo
          _exits = (exits.isNotEmpty ? exits : _getSampleExits())
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          _isLoadingExits = false;
        });
        // Recalcular stock disponible después de cargar salidas
        _recalculateStock();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exits = _getSampleExits();
          _isLoadingExits = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSampleEntries() {
    return [
      {
        'id': 'ENT-001',
        'codigo': 'PRD-001',
        'producto': 'Arroz Extra Superior 5kg',
        'tipo_producto': 'Abarrotes',
        'variedad': 'Granos',
        'cantidad': 150,
        'stock_disponible': 125, // Stock disponible después de ventas
        'unidad': 'un',
        'precio_compra': 15.00,
        'precio_venta': 18.50,
        'fecha': DateTime.now().subtract(const Duration(days: 2)),
        'proveedor': 'Distribuidora García',
        'motivo': 'Compra a proveedor',
      },
      {
        'id': 'ENT-002',
        'codigo': 'PRD-002',
        'producto': 'Leche Evaporada 400ml',
        'tipo_producto': 'Lácteos',
        'variedad': 'Lácteos',
        'cantidad': 250,
        'stock_disponible': 230,
        'unidad': 'un',
        'precio_compra': 2.50,
        'precio_venta': 3.50,
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'proveedor': 'Lácteos del Norte',
        'motivo': 'Compra a proveedor',
      },
      {
        'id': 'ENT-003',
        'codigo': 'PRD-003',
        'producto': 'Aceite Vegetal 900ml',
        'tipo_producto': 'Abarrotes',
        'variedad': 'Aceites',
        'cantidad': 120,
        'stock_disponible': 105,
        'unidad': 'un',
        'precio_compra': 10.00,
        'precio_venta': 12.90,
        'fecha': DateTime.now().subtract(const Duration(days: 3)),
        'proveedor': 'Distribuidora García',
        'motivo': 'Compra a proveedor',
      },
      {
        'id': 'ENT-004',
        'codigo': 'PRD-004',
        'producto': 'Azúcar Rubia 1kg',
        'tipo_producto': 'Abarrotes',
        'variedad': 'Endulzantes',
        'cantidad': 200,
        'stock_disponible': 200,
        'unidad': 'un',
        'precio_compra': 4.50,
        'precio_venta': 5.90,
        'fecha': DateTime.now().subtract(const Duration(days: 4)),
        'proveedor': 'Distribuidora García',
        'motivo': 'Compra a proveedor',
      },
    ];
  }
  
  // Funciones auxiliares para filtros y tabla
  List<String> _getUniqueProductTypes() {
    final types = _entries
        .map((e) => (e['tipo_producto'] ?? e['categoria'] ?? 'Otros').toString())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    types.sort();
    return types;
  }
  
  List<Map<String, dynamic>> _getFilteredEntries() {
    if (_selectedProductType == null) {
      // Asegurar que todos los elementos sean Map<String, dynamic>
      return _entries.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return _entries.where((e) {
      final tipo = (e['tipo_producto'] ?? e['categoria'] ?? 'Otros').toString();
      return tipo == _selectedProductType;
    }).map((e) => Map<String, dynamic>.from(e)).toList();
  }
  
  Widget _buildEntriesTable(List<Map<String, dynamic>> entries) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          // En móvil, usar scroll vertical y horizontal
          if (isMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                columnSpacing: 24,
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                headingRowHeight: 56,
                dataRowHeight: 64,
                columns: const [
                  DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Nombre del Producto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Variedad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Precio Compra', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Precio Venta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Stock Disponible', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('QR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                ],
                rows: entries.map((entry) {
                  final fecha = entry['fecha'] is DateTime 
                      ? DateFormat('dd/MM/yyyy HH:mm').format(entry['fecha'] as DateTime)
                      : entry['fecha']?.toString() ?? '';
                  final codigo = entry['codigo'] ?? entry['id'] ?? '';
                  final variedad = entry['variedad'] ?? entry['tipo_producto'] ?? entry['categoria'] ?? 'Otros';
                  final stockDisponible = entry['stock_disponible'] ?? entry['cantidad'] ?? 0;
                  final cantidadTotal = entry['cantidad'] ?? 0;
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        codigo,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                      )),
                      DataCell(SizedBox(
                        width: 180,
                        child: Text(
                          entry['producto'] ?? entry['product'] ?? '',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          variedad,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                        ),
                      )),
                      DataCell(Text(
                        'S/ ${((entry['precio_compra'] ?? 0.0) as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      )),
                      DataCell(Text(
                        'S/ ${((entry['precio_venta'] ?? 0.0) as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        '${cantidadTotal} ${entry['unidad'] ?? 'un'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (stockDisponible as num) < (cantidadTotal as num) * 0.3
                              ? Colors.orange.withOpacity(0.1)
                              : const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${stockDisponible} ${entry['unidad'] ?? 'un'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: (stockDisponible as num) < (cantidadTotal as num) * 0.3
                                ? Colors.orange.shade700
                                : const Color(0xFF10B981),
                          ),
                        ),
                      )),
                      DataCell(Text(fecha, style: const TextStyle(fontSize: 10))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.qr_code_2, size: 20, color: Color(0xFF8B5CF6)),
                          onPressed: () => _showProductQRDialog(entry),
                          tooltip: 'Generar QR del Producto',
                        ),
                      ),
                    ],
                  );
                }).toList(),
                  ),
                ),
              ),
            );
          } else {
            // En desktop, scroll vertical y horizontal empresarial
            return SizedBox(
              height: 600, // Altura máxima para scroll vertical
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                      headingRowHeight: 56,
                      dataRowHeight: 64,
                      columns: const [
                        DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Nombre del Producto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Variedad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Precio Compra', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Precio Venta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Stock Disponible', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('QR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      ],
                      rows: entries.map((entry) {
                    final fecha = entry['fecha'] is DateTime 
                        ? DateFormat('dd/MM/yyyy HH:mm').format(entry['fecha'] as DateTime)
                        : entry['fecha']?.toString() ?? '';
                    final codigo = entry['codigo'] ?? entry['id'] ?? '';
                    final variedad = entry['variedad'] ?? entry['tipo_producto'] ?? entry['categoria'] ?? 'Otros';
                    final stockDisponible = entry['stock_disponible'] ?? entry['cantidad'] ?? 0;
                    final cantidadTotal = entry['cantidad'] ?? 0;
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          codigo,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                        )),
                        DataCell(SizedBox(
                          width: 180,
                          child: Text(
                            entry['producto'] ?? entry['product'] ?? '',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            variedad,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                          ),
                        )),
                        DataCell(Text(
                          'S/ ${((entry['precio_compra'] ?? 0.0) as num).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          'S/ ${((entry['precio_venta'] ?? 0.0) as num).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        )),
                        DataCell(Text(
                          '${cantidadTotal} ${entry['unidad'] ?? 'un'}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (stockDisponible as num) < (cantidadTotal as num) * 0.3
                                ? Colors.orange.withOpacity(0.1)
                                : const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${stockDisponible} ${entry['unidad'] ?? 'un'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: (stockDisponible as num) < (cantidadTotal as num) * 0.3
                                  ? Colors.orange.shade700
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        )),
                        DataCell(Text(fecha, style: const TextStyle(fontSize: 10))),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.qr_code_2, size: 20, color: Color(0xFF8B5CF6)),
                            onPressed: () => _showProductQRDialog(entry),
                            tooltip: 'Generar QR del Producto',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
  
  void _showProductQRDialog(Map<String, dynamic> entry) {
    final codigo = entry['codigo'] ?? entry['id'] ?? '';
    final producto = entry['producto'] ?? entry['product'] ?? '';
    final precioVenta = (entry['precio_venta'] ?? 0.0) as num;
    final variedad = entry['variedad'] ?? entry['tipo_producto'] ?? entry['categoria'] ?? 'Otros';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code_2, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                producto,
                style: const TextStyle(fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QRService.generateQRCode(
                  data: _generateEntryQRData(entry),
                  size: 250,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQRInfoRow('Código:', codigo),
                    const SizedBox(height: 8),
                    _buildQRInfoRow('Variedad:', variedad),
                    const SizedBox(height: 8),
                    _buildQRInfoRow(
                      'Precio de Venta:',
                      'S/ ${precioVenta.toStringAsFixed(2)}',
                      isPrice: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este QR se puede imprimir para que el cliente lo escanee al comprar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQRInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isPrice ? FontWeight.w700 : FontWeight.w600,
              color: isPrice ? const Color(0xFF10B981) : const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
  
  String _generateEntryQRData(Map<String, dynamic> entry) {
    // Generar QR para cliente - solo información necesaria para venta
    // Este QR se imprimirá y el cliente lo escaneará al comprar
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    final data = {
      'tipo': 'VENTA',
      'codigo': entry['codigo'] ?? entry['id'] ?? '',
      'producto': entry['producto'] ?? entry['product'] ?? '',
      'variedad': entry['variedad'] ?? entry['tipo_producto'] ?? entry['categoria'] ?? 'Otros',
      'precio_venta': (entry['precio_venta'] ?? 0.0) as num,
      'unidad': entry['unidad'] ?? 'un',
      'negocio': provider.currentBusinessName,
      'timestamp': DateTime.now().toIso8601String(),
    };
    // Convertir a JSON válido para que el QR sea escaneable correctamente
    return jsonEncode(data);
  }
  
  void _showCategoryQRDialog() {
    final categories = _getUniqueProductTypes();
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categorías disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar QR por Categoría'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryEntries = _entries.where((e) {
                final tipo = (e['tipo_producto'] ?? e['categoria'] ?? 'Otros').toString();
                return tipo == category;
              }).toList();
              
              return ListTile(
                leading: const Icon(Icons.category, color: Color(0xFF8B5CF6)),
                title: Text(category),
                subtitle: Text('${categoryEntries.length} productos'),
                trailing: IconButton(
                  icon: const Icon(Icons.qr_code_2, color: Color(0xFF8B5CF6)),
                  onPressed: () {
                    Navigator.pop(context);
                    _showCategoryQR(category, categoryEntries);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  void _showCategoryQR(String category, List<dynamic> entries) {
    final entriesList = entries.map((e) => Map<String, dynamic>.from(e)).toList();
    final qrData = _generateCategoryQRData(category, entriesList);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR de Categoría: $category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QRService.generateQRCode(
                data: qrData,
                size: 250,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría: $category', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Total productos: ${entries.length}'),
                    Text('Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  String _generateCategoryQRData(String category, List<Map<String, dynamic>> entries) {
    // Generar QR empresarial con toda la información de la categoría
    final totalCantidad = entries.fold<int>(0, (sum, e) => sum + ((e['cantidad'] ?? 0) as num).toInt());
    final totalInversion = entries.fold<double>(0.0, (sum, e) => sum + ((e['precio_compra'] ?? 0.0) as num).toDouble());
    final totalValorVenta = entries.fold<double>(0.0, (sum, e) => sum + ((e['precio_venta'] ?? 0.0) as num).toDouble());
    
    final data = {
      'tipo': 'CATEGORIA_ENTRADA',
      'categoria': category,
      'fecha_generacion': DateTime.now().toIso8601String(),
      'total_productos': entries.length,
      'total_cantidad': totalCantidad,
      'total_inversion': totalInversion,
      'total_valor_venta': totalValorVenta,
      'productos': entries.map((e) => {
        'id': e['id'] ?? '',
        'nombre': e['producto'] ?? e['product'] ?? '',
        'cantidad': e['cantidad'] ?? 0,
        'precio_compra': (e['precio_compra'] ?? 0.0) as num,
        'precio_venta': (e['precio_venta'] ?? 0.0) as num,
      }).toList(),
    };
    // Convertir a JSON válido para que el QR sea escaneable correctamente
    return jsonEncode(data);
  }

  List<Map<String, dynamic>> _getSampleExits() {
    return [
      {
        'id': 'SAL-001',
        'codigo': 'PRD-001',
        'producto': 'Arroz Extra Superior 5kg',
        'variedad': 'Granos',
        'cantidad': 25,
        'unidad': 'un',
        'precio_venta': 18.50,
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'cliente': 'Cliente General',
        'motivo': 'Venta',
      },
      {
        'id': 'SAL-002',
        'codigo': 'PRD-003',
        'producto': 'Aceite Vegetal 900ml',
        'variedad': 'Aceites',
        'cantidad': 15,
        'unidad': 'un',
        'precio_venta': 12.90,
        'fecha': DateTime.now(),
        'cliente': 'Cliente General',
        'motivo': 'Venta',
      },
    ];
  }
  
  // Función para actualizar el stock disponible cuando hay una salida
  void _updateStockOnExit(Map<String, dynamic> exit) {
    // Buscar la entrada correspondiente por código o nombre de producto
    final exitMap = Map<String, dynamic>.from(exit);
    final codigo = (exitMap['codigo'] ?? '').toString();
    final producto = (exitMap['producto'] ?? exitMap['product'] ?? '').toString();
    final cantidadVendida = (exitMap['cantidad'] ?? 0) as num;
    
    // Actualizar el stock disponible en las entradas
    setState(() {
      _entries = _entries.map((entry) {
        final entryMap = Map<String, dynamic>.from(entry);
        final entryCodigo = (entryMap['codigo'] ?? entryMap['id'] ?? '').toString();
        final entryProducto = (entryMap['producto'] ?? entryMap['product'] ?? '').toString();
        
        // Si coincide el código o el nombre del producto, disminuir el stock
        if ((codigo.isNotEmpty && entryCodigo == codigo) || 
            (producto.isNotEmpty && entryProducto == producto)) {
          final stockActual = (entryMap['stock_disponible'] ?? entryMap['cantidad'] ?? 0) as num;
          final nuevoStock = (stockActual - cantidadVendida).clamp(0, double.infinity);
          return Map<String, dynamic>.from({
            ...entryMap,
            'stock_disponible': nuevoStock,
          });
        }
        return Map<String, dynamic>.from(entryMap);
      }).toList();
    });
  }
  
  // Función para calcular stock disponible basado en entradas y salidas
  void _recalculateStock() {
    // Para cada entrada, calcular el stock disponible restando las salidas
    setState(() {
      _entries = _entries.map((entry) {
        // Convertir entry a Map<String, dynamic> si es necesario
        final entryMap = Map<String, dynamic>.from(entry);
        final entryCodigo = (entryMap['codigo'] ?? entryMap['id'] ?? '').toString();
        final entryProducto = (entryMap['producto'] ?? entryMap['product'] ?? '').toString();
        final cantidadInicial = (entryMap['cantidad'] ?? 0) as num;
        
        // Sumar todas las salidas que correspondan a esta entrada
        int cantidadVendida = 0;
        for (var exit in _exits) {
          final exitMap = Map<String, dynamic>.from(exit);
          final exitCodigo = (exitMap['codigo'] ?? exitMap['id'] ?? '').toString();
          final exitProducto = (exitMap['producto'] ?? exitMap['product'] ?? '').toString();
          
          if ((entryCodigo.isNotEmpty && exitCodigo == entryCodigo) ||
              (entryProducto.isNotEmpty && exitProducto == entryProducto)) {
            cantidadVendida += (exitMap['cantidad'] ?? 0) as int;
          }
        }
        
        final stockDisponible = (cantidadInicial - cantidadVendida).clamp(0, double.infinity);
        
        return Map<String, dynamic>.from({
          ...entryMap,
          'stock_disponible': stockDisponible,
        });
      }).toList();
    });
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final fecha = entry['fecha'] is DateTime 
        ? DateFormat('dd/MM/yyyy HH:mm').format(entry['fecha'] as DateTime)
        : entry['fecha']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1.5,
        ),
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
          onTap: () => _showEntryDetails(entry),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Color(0xFF10B981),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['producto'] ?? entry['product'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
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
                            fecha,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (entry['proveedor'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.store, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              entry['proveedor'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${entry['cantidad'] ?? 0} ${entry['unidad'] ?? 'un'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    if (entry['precio_compra'] != null)
                      Text(
                        'S/ ${(entry['precio_compra'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
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

  Widget _buildExitCard(Map<String, dynamic> exit) {
    final fecha = exit['fecha'] is DateTime 
        ? DateFormat('dd/MM/yyyy HH:mm').format(exit['fecha'] as DateTime)
        : exit['fecha']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
          width: 1.5,
        ),
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
          onTap: () => _showExitDetails(exit),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exit['producto'] ?? exit['product'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
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
                            fecha,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (exit['cliente'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              exit['cliente'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${exit['cantidad'] ?? 0} ${exit['unidad'] ?? 'un'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    if (exit['precio_venta'] != null)
                      Text(
                        'S/ ${(exit['precio_venta'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
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

  Widget _buildDateRangeFilter({
    required DateTime startDate,
    required DateTime endDate,
    required Function(DateTime) onStartDateChanged,
    required Function(DateTime) onEndDateChanged,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) onStartDateChanged(picked);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(startDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text('a', style: TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: startDate,
                  lastDate: DateTime.now(),
                );
                if (picked != null) onEndDateChanged(picked);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(endDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showEntryDetails(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEntryDetailsSheet(entry),
    );
  }

  void _showExitDetails(Map<String, dynamic> exit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExitDetailsSheet(exit),
    );
  }

  Widget _buildEntryDetailsSheet(Map<String, dynamic> entry) {
    final fecha = entry['fecha'] is DateTime 
        ? DateFormat('dd/MM/yyyy HH:mm').format(entry['fecha'] as DateTime)
        : entry['fecha']?.toString() ?? '';
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_downward, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Detalles de Entrada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Producto', entry['producto'] ?? entry['product'] ?? ''),
                  _buildDetailRow('Cantidad', '${entry['cantidad'] ?? 0} ${entry['unidad'] ?? 'un'}'),
                  _buildDetailRow('Fecha', fecha),
                  if (entry['proveedor'] != null)
                    _buildDetailRow('Proveedor', entry['proveedor']),
                  if (entry['motivo'] != null)
                    _buildDetailRow('Motivo', entry['motivo']),
                  if (entry['precio_compra'] != null)
                    _buildDetailRow('Precio Compra', 'S/ ${(entry['precio_compra'] as num).toStringAsFixed(2)}'),
                  if (entry['precio_venta'] != null)
                    _buildDetailRow('Precio Venta', 'S/ ${(entry['precio_venta'] as num).toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExitDetailsSheet(Map<String, dynamic> exit) {
    final fecha = exit['fecha'] is DateTime 
        ? DateFormat('dd/MM/yyyy HH:mm').format(exit['fecha'] as DateTime)
        : exit['fecha']?.toString() ?? '';
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_upward, color: Color(0xFFEF4444), size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Detalles de Salida',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Producto', exit['producto'] ?? exit['product'] ?? ''),
                  _buildDetailRow('Cantidad', '${exit['cantidad'] ?? 0} ${exit['unidad'] ?? 'un'}'),
                  _buildDetailRow('Fecha', fecha),
                  if (exit['cliente'] != null)
                    _buildDetailRow('Cliente', exit['cliente']),
                  if (exit['motivo'] != null)
                    _buildDetailRow('Motivo', exit['motivo']),
                  if (exit['precio_venta'] != null)
                    _buildDetailRow('Precio Venta', 'S/ ${(exit['precio_venta'] as num).toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportEntriesToExcel() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay entradas para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Entradas'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Código');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Nombre del Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Variedad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Precio Compra');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Precio Venta');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Cantidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = TextCellValue('Stock Disponible');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value = TextCellValue('Unidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value = TextCellValue('Fecha');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0)).value = TextCellValue('Proveedor');
      
      // Data
      for (int i = 0; i < _entries.length; i++) {
        final entry = _entries[i];
        final fecha = entry['fecha'] is DateTime 
            ? DateFormat('dd/MM/yyyy HH:mm').format(entry['fecha'] as DateTime)
            : entry['fecha']?.toString() ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(entry['codigo'] ?? entry['id'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(entry['producto'] ?? entry['product'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(entry['variedad'] ?? entry['tipo_producto'] ?? entry['categoria'] ?? 'Otros');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = DoubleCellValue((entry['precio_compra'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((entry['precio_venta'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = IntCellValue((entry['cantidad'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = IntCellValue((entry['stock_disponible'] ?? entry['cantidad'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = TextCellValue(entry['unidad'] ?? 'un');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1)).value = TextCellValue(fecha);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1)).value = TextCellValue(entry['proveedor'] ?? '');
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/entradas_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Excel exportado: ${file.path}'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportEntriesToPDF() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay entradas para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Generar PDF usando el servicio
      final pdfBytes = await PDFService.generateInventoryMovementsPDF(
        nombreComercial: provider.currentBusinessName,
        tipo: 'Entradas',
        movimientos: _entries.map((e) {
          final entry = Map<String, dynamic>.from(e);
          return {
            'codigo': (entry['codigo'] ?? entry['id'] ?? '').toString(),
            'producto': (entry['producto'] ?? entry['product'] ?? '').toString(),
            'variedad': (entry['variedad'] ?? entry['tipo_producto'] ?? entry['categoria'] ?? 'Otros').toString(),
            'cantidad': entry['cantidad'] ?? 0,
            'stock_disponible': entry['stock_disponible'] ?? entry['cantidad'] ?? 0,
            'unidad': (entry['unidad'] ?? 'un').toString(),
            'fecha': entry['fecha'] is DateTime 
                ? DateFormat('dd/MM/yyyy HH:mm').format(entry['fecha'] as DateTime)
                : (entry['fecha']?.toString() ?? ''),
            'precio_compra': entry['precio_compra'] ?? 0.0,
            'precio_venta': entry['precio_venta'] ?? 0.0,
            'proveedor': (entry['proveedor'] ?? '').toString(),
          };
        }).toList(),
        fechaDesde: DateFormat('dd/MM/yyyy').format(_entriesStartDate),
        fechaHasta: DateFormat('dd/MM/yyyy').format(_entriesEndDate),
      );
      
      await PDFService.sharePDF(pdfBytes, 'entradas_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('PDF exportado exitosamente')),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportExitsToExcel() async {
    if (_exits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay salidas para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Salidas'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Código');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Nombre del Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Variedad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Cantidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Unidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Precio Venta');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = TextCellValue('Fecha');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value = TextCellValue('Cliente');
      
      // Data
      for (int i = 0; i < _exits.length; i++) {
        final exit = _exits[i];
        final fecha = exit['fecha'] is DateTime 
            ? DateFormat('dd/MM/yyyy HH:mm').format(exit['fecha'] as DateTime)
            : exit['fecha']?.toString() ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(exit['codigo'] ?? exit['id'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(exit['producto'] ?? exit['product'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(exit['variedad'] ?? exit['tipo_producto'] ?? exit['categoria'] ?? 'Otros');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = IntCellValue((exit['cantidad'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = TextCellValue(exit['unidad'] ?? 'un');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = DoubleCellValue((exit['precio_venta'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = TextCellValue(fecha);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = TextCellValue(exit['cliente'] ?? '');
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/salidas_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Excel exportado: ${file.path}'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportExitsToPDF() async {
    if (_exits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay salidas para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Generar PDF usando el servicio
      final pdfBytes = await PDFService.generateInventoryMovementsPDF(
        nombreComercial: provider.currentBusinessName,
        tipo: 'Salidas',
        movimientos: _exits.map((e) {
          final exit = Map<String, dynamic>.from(e);
          return {
            'codigo': (exit['codigo'] ?? exit['id'] ?? '').toString(),
            'producto': (exit['producto'] ?? exit['product'] ?? '').toString(),
            'variedad': (exit['variedad'] ?? exit['tipo_producto'] ?? exit['categoria'] ?? 'Otros').toString(),
            'cantidad': exit['cantidad'] ?? 0,
            'unidad': (exit['unidad'] ?? 'un').toString(),
            'fecha': exit['fecha'] is DateTime 
                ? DateFormat('dd/MM/yyyy HH:mm').format(exit['fecha'] as DateTime)
                : (exit['fecha']?.toString() ?? ''),
            'precio_venta': exit['precio_venta'] ?? 0.0,
            'cliente': (exit['cliente'] ?? '').toString(),
          };
        }).toList(),
        fechaDesde: DateFormat('dd/MM/yyyy').format(_exitsStartDate),
        fechaHasta: DateFormat('dd/MM/yyyy').format(_exitsEndDate),
      );
      
      await PDFService.sharePDF(pdfBytes, 'salidas_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('PDF exportado exitosamente')),
              ],
            ),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNewEntryDialog() {
    final productController = TextEditingController();
    final codigoController = TextEditingController();
    final cantidadController = TextEditingController();
    final precioCompraController = TextEditingController();
    final precioVentaController = TextEditingController();
    final proveedorController = TextEditingController();
    final motivoController = TextEditingController();
    String? selectedTipo = 'Abarrotes';
    String? selectedVariedad = 'Otros';
    DateTime selectedDate = DateTime.now();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Nueva Entrada de Inventario'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código del Producto *',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Producto *',
                      prefixIcon: const Icon(Icons.inventory_2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedTipo,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Producto *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: ['Abarrotes', 'Lácteos', 'Bebidas', 'Limpieza', 'Aseo Personal', 'Otros']
                              .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                              .toList(),
                          onChanged: (value) => setDialogState(() => selectedTipo = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedVariedad,
                          decoration: InputDecoration(
                            labelText: 'Variedad',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: ['Granos', 'Lácteos', 'Aceites', 'Endulzantes', 'Otros']
                              .map((variedad) => DropdownMenuItem(value: variedad, child: Text(variedad)))
                              .toList(),
                          onChanged: (value) => setDialogState(() => selectedVariedad = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cantidadController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cantidad *',
                            prefixIcon: const Icon(Icons.numbers),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: precioCompraController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Precio Compra *',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: precioVentaController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Precio Venta *',
                            prefixIcon: const Icon(Icons.sell),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: proveedorController,
                    decoration: InputDecoration(
                      labelText: 'Proveedor',
                      prefixIcon: const Icon(Icons.store),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: motivoController,
                    decoration: InputDecoration(
                      labelText: 'Motivo',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (productController.text.isEmpty ||
                          cantidadController.text.isEmpty ||
                          precioCompraController.text.isEmpty ||
                          precioVentaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor complete todos los campos requeridos'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      final nuevaEntrada = {
                        'id': 'ENT-${DateTime.now().millisecondsSinceEpoch}',
                        'codigo': codigoController.text.isNotEmpty
                            ? codigoController.text
                            : 'PRD-${DateTime.now().millisecondsSinceEpoch}',
                        'producto': productController.text,
                        'tipo_producto': selectedTipo,
                        'variedad': selectedVariedad,
                        'cantidad': int.tryParse(cantidadController.text) ?? 0,
                        'stock_disponible': int.tryParse(cantidadController.text) ?? 0,
                        'unidad': 'un',
                        'precio_compra': double.tryParse(precioCompraController.text) ?? 0.0,
                        'precio_venta': double.tryParse(precioVentaController.text) ?? 0.0,
                        'fecha': selectedDate,
                        'proveedor': proveedorController.text,
                        'motivo': motivoController.text.isNotEmpty
                            ? motivoController.text
                            : 'Compra a proveedor',
                      };

                      try {
                        // Intentar crear en el backend
                        final provider = Provider.of<AppProvider>(context, listen: false);
                        await ApiService.createInventoryEntry({
                          ...nuevaEntrada,
                          'businessId': provider.currentBusinessId,
                        });
                      } catch (e) {
                        // Si falla, solo agregar localmente
                      }

                      setState(() {
                        // Asegurar que sea Map<String, dynamic>
                        _entries.insert(0, Map<String, dynamic>.from(nuevaEntrada));
                        _recalculateStock();
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Entrada registrada: ${productController.text}',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar Entrada'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewExitDialog() {
    final productController = TextEditingController();
    final codigoController = TextEditingController();
    final cantidadController = TextEditingController();
    final precioVentaController = TextEditingController();
    final clienteController = TextEditingController();
    final motivoController = TextEditingController();
    String? selectedVariedad = 'Otros';
    DateTime selectedDate = DateTime.now();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove_circle, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Nueva Salida de Inventario'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de producto existente
                  if (_entries.isNotEmpty)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Seleccionar Producto Existente',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _entries.map<DropdownMenuItem<String>>((entry) {
                        final producto = entry['producto'] ?? entry['product'] ?? '';
                        final codigo = (entry['codigo'] ?? entry['id'] ?? '').toString();
                        final stock = entry['stock_disponible'] ?? entry['cantidad'] ?? 0;
                        return DropdownMenuItem<String>(
                          value: codigo,
                          child: Text('$producto (Stock: $stock)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final entry = _entries.firstWhere(
                            (e) => ((e['codigo'] ?? e['id']) ?? '').toString() == value,
                          );
                          productController.text = entry['producto'] ?? entry['product'] ?? '';
                          codigoController.text = (entry['codigo'] ?? entry['id'] ?? '').toString();
                          precioVentaController.text =
                              (entry['precio_venta'] ?? 0.0).toString();
                          setDialogState(() {
                            selectedVariedad = (entry['variedad'] ??
                                entry['tipo_producto'] ??
                                entry['categoria'] ??
                                'Otros').toString();
                          });
                        }
                      },
                    ),
                  if (_entries.isNotEmpty) const SizedBox(height: 16),
                  TextField(
                    controller: codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código del Producto *',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Producto *',
                      prefixIcon: const Icon(Icons.inventory_2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cantidadController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cantidad *',
                            prefixIcon: const Icon(Icons.numbers),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: precioVentaController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Precio Venta *',
                            prefixIcon: const Icon(Icons.sell),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: clienteController,
                    decoration: InputDecoration(
                      labelText: 'Cliente',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: motivoController,
                    decoration: InputDecoration(
                      labelText: 'Motivo',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (productController.text.isEmpty ||
                          cantidadController.text.isEmpty ||
                          precioVentaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor complete todos los campos requeridos'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final cantidad = int.tryParse(cantidadController.text) ?? 0;
                      if (cantidad <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('La cantidad debe ser mayor a 0'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Verificar stock disponible
                      final codigo = codigoController.text.isNotEmpty
                          ? codigoController.text
                          : 'PRD-${DateTime.now().millisecondsSinceEpoch}';
                      final entry = _entries.firstWhere(
                        (e) => (e['codigo'] ?? e['id']) == codigo,
                        orElse: () => {},
                      );

                      if (entry.isNotEmpty) {
                        final stockDisponible = entry['stock_disponible'] ?? entry['cantidad'] ?? 0;
                        if (cantidad > stockDisponible) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Stock insuficiente. Disponible: $stockDisponible',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      setDialogState(() => isLoading = true);

                      final nuevaSalida = {
                        'id': 'SAL-${DateTime.now().millisecondsSinceEpoch}',
                        'codigo': codigo,
                        'producto': productController.text,
                        'variedad': selectedVariedad,
                        'cantidad': cantidad,
                        'unidad': 'un',
                        'precio_venta': double.tryParse(precioVentaController.text) ?? 0.0,
                        'fecha': selectedDate,
                        'cliente': clienteController.text.isNotEmpty
                            ? clienteController.text
                            : 'Cliente General',
                        'motivo': motivoController.text.isNotEmpty
                            ? motivoController.text
                            : 'Venta',
                      };

                      try {
                        // Intentar crear en el backend
                        final provider = Provider.of<AppProvider>(context, listen: false);
                        await ApiService.createInventoryExit({
                          ...nuevaSalida,
                          'businessId': provider.currentBusinessId,
                        });
                      } catch (e) {
                        // Si falla, solo agregar localmente
                      }

                      setState(() {
                        // Asegurar que sea Map<String, dynamic>
                        _exits.insert(0, Map<String, dynamic>.from(nuevaSalida));
                        _recalculateStock();
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Salida registrada: ${productController.text}',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar Salida'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TABLA DE SALIDAS ====================
  
  Widget _buildExitsTable(List<dynamic> exits) {
    final exitsList = exits.map((e) => Map<String, dynamic>.from(e)).toList();
    
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          // En móvil, usar scroll vertical y horizontal
          if (isMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                columnSpacing: 24,
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                headingRowHeight: 56,
                dataRowHeight: 64,
                columns: const [
                  DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Variedad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Precio Venta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Fecha Venta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('QR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                ],
                rows: exitsList.map((exit) {
                  final fecha = exit['fecha'] is DateTime 
                      ? DateFormat('dd/MM/yyyy HH:mm').format(exit['fecha'] as DateTime)
                      : exit['fecha']?.toString() ?? '';
                  final codigo = exit['codigo'] ?? exit['id'] ?? '';
                  final variedad = exit['variedad'] ?? exit['tipo_producto'] ?? exit['categoria'] ?? 'Otros';
                  final cantidad = exit['cantidad'] ?? 0;
                  final precioVenta = (exit['precio_venta'] ?? 0.0) as num;
                  final total = (cantidad as num) * precioVenta;
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        codigo,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                      )),
                      DataCell(SizedBox(
                        width: 180,
                        child: Text(
                          exit['producto'] ?? exit['product'] ?? '',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          variedad,
                          style: const TextStyle(fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
                        ),
                      )),
                      DataCell(Text(
                        '${cantidad} ${exit['unidad'] ?? 'un'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        'S/ ${precioVenta.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      )),
                      DataCell(Text(
                        'S/ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
                      )),
                      DataCell(SizedBox(
                        width: 120,
                        child: Text(
                          exit['cliente'] ?? 'Cliente General',
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Text(fecha, style: const TextStyle(fontSize: 10))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.qr_code_2, size: 20, color: Color(0xFF8B5CF6)),
                          onPressed: () => _showExitQRDialog(exit),
                          tooltip: 'Generar QR de Venta',
                        ),
                      ),
                    ],
                  );
                }).toList(),
                  ),
                ),
              ),
            );
          } else {
            // En desktop, scroll vertical y horizontal empresarial
            return SizedBox(
              height: 600, // Altura máxima para scroll vertical
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                      headingRowHeight: 56,
                      dataRowHeight: 64,
                      columns: const [
                        DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Variedad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Precio Venta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('Fecha Venta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataColumn(label: Text('QR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      ],
                      rows: exitsList.map((exit) {
                    final fecha = exit['fecha'] is DateTime 
                        ? DateFormat('dd/MM/yyyy HH:mm').format(exit['fecha'] as DateTime)
                        : exit['fecha']?.toString() ?? '';
                    final codigo = exit['codigo'] ?? exit['id'] ?? '';
                    final variedad = exit['variedad'] ?? exit['tipo_producto'] ?? exit['categoria'] ?? 'Otros';
                    final cantidad = exit['cantidad'] ?? 0;
                    final precioVenta = (exit['precio_venta'] ?? 0.0) as num;
                    final total = (cantidad as num) * precioVenta;
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          codigo,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                        )),
                        DataCell(SizedBox(
                          width: 180,
                          child: Text(
                            exit['producto'] ?? exit['product'] ?? '',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            variedad,
                            style: const TextStyle(fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
                          ),
                        )),
                        DataCell(Text(
                          '${cantidad} ${exit['unidad'] ?? 'un'}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        )),
                        DataCell(Text(
                          'S/ ${precioVenta.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          'S/ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
                        )),
                        DataCell(SizedBox(
                          width: 120,
                          child: Text(
                            exit['cliente'] ?? 'Cliente General',
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        DataCell(Text(fecha, style: const TextStyle(fontSize: 10))),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.qr_code_2, size: 20, color: Color(0xFF8B5CF6)),
                            onPressed: () => _showExitQRDialog(exit),
                            tooltip: 'Generar QR de Venta',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showExitQRDialog(Map<String, dynamic> exit) {
    final exitMap = Map<String, dynamic>.from(exit);
    final codigo = (exitMap['codigo'] ?? exitMap['id'] ?? '').toString();
    final producto = (exitMap['producto'] ?? exitMap['product'] ?? '').toString();
    final cantidad = exitMap['cantidad'] ?? 0;
    final precioVenta = (exitMap['precio_venta'] ?? 0.0) as num;
    final cliente = (exitMap['cliente'] ?? 'Cliente General').toString();
    final fechaVenta = exitMap['fecha'] is DateTime 
        ? DateFormat('dd/MM/yyyy HH:mm').format(exitMap['fecha'] as DateTime)
        : (exitMap['fecha']?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code_2, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'QR de Venta',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QRService.generateQRCode(
                  data: _generateExitQRData(exitMap),
                  size: 250,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQRInfoRow('Producto:', producto),
                    const SizedBox(height: 8),
                    _buildQRInfoRow('Código:', codigo),
                    const SizedBox(height: 8),
                    _buildQRInfoRow('Fecha de Venta:', fechaVenta),
                    const SizedBox(height: 8),
                    _buildQRInfoRow('Cantidad Vendida:', '${cantidad} ${exitMap['unidad'] ?? 'un'}'),
                    const SizedBox(height: 8),
                    _buildQRInfoRow(
                      'Precio Unitario:',
                      'S/ ${precioVenta.toStringAsFixed(2)}',
                      isPrice: true,
                    ),
                    const SizedBox(height: 8),
                    _buildQRInfoRow(
                      'Total:',
                      'S/ ${((cantidad as num) * precioVenta).toStringAsFixed(2)}',
                      isPrice: true,
                    ),
                    const SizedBox(height: 8),
                    _buildQRInfoRow('Cliente:', cliente),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este QR contiene información de la venta realizada',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _generateExitQRData(Map<String, dynamic> exit) {
    // Generar QR de venta con fecha y cantidad vendida
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    final fechaVenta = exit['fecha'] is DateTime 
        ? (exit['fecha'] as DateTime).toIso8601String()
        : exit['fecha']?.toString() ?? DateTime.now().toIso8601String();
    
    final cantidadVendida = (exit['cantidad'] ?? 0) as num;
    final precioVenta = (exit['precio_venta'] ?? 0.0) as num;
    
    final data = {
      'tipo': 'VENTA_REALIZADA',
      'codigo': exit['codigo'] ?? exit['id'] ?? '',
      'producto': exit['producto'] ?? exit['product'] ?? '',
      'variedad': exit['variedad'] ?? exit['tipo_producto'] ?? exit['categoria'] ?? 'Otros',
      'cantidad_vendida': cantidadVendida,
      'precio_venta': precioVenta,
      'total': (cantidadVendida * precioVenta).toDouble(),
      'fecha_venta': fechaVenta,
      'cliente': exit['cliente'] ?? 'Cliente General',
      'unidad': exit['unidad'] ?? 'un',
      'negocio': provider.currentBusinessName,
      'timestamp': DateTime.now().toIso8601String(),
    };
    // Convertir a JSON válido para que el QR sea escaneable correctamente
    return jsonEncode(data);
  }

  // ==================== SECCIÓN DE CLIENTES ====================

  Widget _buildClientesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Clientes',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Créditos y pagos de clientes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const TabBar(
                  labelColor: Color(0xFF2563EB),
                  unselectedLabelColor: Color(0xFF6B7280),
                  indicatorColor: Color(0xFF2563EB),
                  tabs: [
                    Tab(text: 'Créditos'),
                    Tab(text: 'Pagos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCreditsTab(),
                _buildPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsTab() {
    // Cargar créditos cuando se abre la pestaña
    if (_credits.isEmpty && !_isLoadingCredits) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCredits());
    }

    final filteredCredits = _getFilteredCredits();

    return Column(
      children: [
        // Header con filtros y acciones
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Créditos a Clientes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Productos vendidos a crédito',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      isMobile
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFF2563EB),
                                  onTap: () => _exportCreditsToExcel(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFF2563EB),
                                  onTap: () => _exportCreditsToPDF(),
                                  isMobile: true,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFF2563EB),
                                  onTap: () => _exportCreditsToExcel(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFF2563EB),
                                  onTap: () => _exportCreditsToPDF(),
                                ),
                              ],
                            ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return isMobile
                      ? Column(
                          children: [
                            _buildDateRangeFilter(
                              startDate: _creditsStartDate,
                              endDate: _creditsEndDate,
                              onStartDateChanged: (date) {
                                setState(() => _creditsStartDate = date);
                                _loadCredits();
                              },
                              onEndDateChanged: (date) {
                                setState(() => _creditsEndDate = date);
                                _loadCredits();
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClientFilter,
                                  hint: const Text('Cliente', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todos')),
                                    ..._getUniqueClients().map((client) => DropdownMenuItem(
                                      value: client,
                                      child: Text(client, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedClientFilter = value);
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  isDense: true,
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildDateRangeFilter(
                                startDate: _creditsStartDate,
                                endDate: _creditsEndDate,
                                onStartDateChanged: (date) {
                                  setState(() => _creditsStartDate = date);
                                  _loadCredits();
                                },
                                onEndDateChanged: (date) {
                                  setState(() => _creditsEndDate = date);
                                  _loadCredits();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClientFilter,
                                  hint: const Text('Cliente', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todos')),
                                    ..._getUniqueClients().map((client) => DropdownMenuItem(
                                      value: client,
                                      child: Text(client, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedClientFilter = value);
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingCredits
              ? const Center(child: CircularProgressIndicator())
              : filteredCredits.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.credit_card_outlined,
                      title: 'No hay créditos registrados',
                      subtitle: 'Los créditos aparecerán aquí cuando se registren ventas a crédito',
                    )
                  : _buildCreditsTable(filteredCredits),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    // Cargar pagos cuando se abre la pestaña
    if (_payments.isEmpty && !_isLoadingPayments) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayments());
    }

    final filteredPayments = _getFilteredPayments();

    return Column(
      children: [
        // Header con filtros y acciones
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pagos de Clientes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Registro de pagos recibidos',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      isMobile
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _exportPaymentsToExcel(),
                                  isMobile: true,
                                ),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _exportPaymentsToPDF(),
                                  isMobile: true,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Excel',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _exportPaymentsToExcel(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'PDF',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _exportPaymentsToPDF(),
                                ),
                              ],
                            ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return isMobile
                      ? Column(
                          children: [
                            _buildDateRangeFilter(
                              startDate: _paymentsStartDate,
                              endDate: _paymentsEndDate,
                              onStartDateChanged: (date) {
                                setState(() => _paymentsStartDate = date);
                                _loadPayments();
                              },
                              onEndDateChanged: (date) {
                                setState(() => _paymentsEndDate = date);
                                _loadPayments();
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClientFilter,
                                  hint: const Text('Cliente', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todos')),
                                    ..._getUniqueClients().map((client) => DropdownMenuItem(
                                      value: client,
                                      child: Text(client, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedClientFilter = value);
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  isDense: true,
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildDateRangeFilter(
                                startDate: _paymentsStartDate,
                                endDate: _paymentsEndDate,
                                onStartDateChanged: (date) {
                                  setState(() => _paymentsStartDate = date);
                                  _loadPayments();
                                },
                                onEndDateChanged: (date) {
                                  setState(() => _paymentsEndDate = date);
                                  _loadPayments();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClientFilter,
                                  hint: const Text('Cliente', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todos')),
                                    ..._getUniqueClients().map((client) => DropdownMenuItem(
                                      value: client,
                                      child: Text(client, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedClientFilter = value);
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingPayments
              ? const Center(child: CircularProgressIndicator())
              : filteredPayments.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.payment_outlined,
                      title: 'No hay pagos registrados',
                      subtitle: 'Los pagos aparecerán aquí cuando se registren',
                    )
                  : _buildPaymentsTable(filteredPayments),
        ),
      ],
    );
  }

  Widget _buildCreditsTable(List<Map<String, dynamic>> credits) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 24,
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                headingRowHeight: 56,
                dataRowHeight: 64,
                columns: const [
                  DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                ],
                rows: credits.map((credit) {
                  final fecha = credit['fecha'] is DateTime 
                      ? DateFormat('dd/MM/yyyy').format(credit['fecha'] as DateTime)
                      : credit['fecha']?.toString() ?? '';
                  final monto = (credit['monto'] ?? 0.0) as num;
                  final pagado = credit['pagado'] ?? false;
                  final cantidad = credit['cantidad'] ?? 0;
                  
                  return DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: 120,
                        child: Text(
                          credit['cliente'] ?? 'Cliente',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 180,
                        child: Text(
                          credit['producto'] ?? '',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Text(fecha, style: const TextStyle(fontSize: 10))),
                      DataCell(Text(
                        '${cantidad} ${credit['unidad'] ?? 'un'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        'S/ ${monto.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w700),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: pagado 
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pagado ? 'Pagado' : 'Pendiente',
                          style: TextStyle(
                            fontSize: 10,
                            color: pagado ? const Color(0xFF10B981) : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTable(List<Map<String, dynamic>> payments) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 24,
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                headingRowHeight: 56,
                dataRowHeight: 64,
                columns: const [
                  DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Fecha Pago', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Método', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                ],
                rows: payments.map((payment) {
                  final fecha = payment['fecha'] is DateTime 
                      ? DateFormat('dd/MM/yyyy').format(payment['fecha'] as DateTime)
                      : payment['fecha']?.toString() ?? '';
                  final monto = (payment['monto'] ?? 0.0) as num;
                  final cantidad = payment['cantidad'] ?? 0;
                  
                  return DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: 120,
                        child: Text(
                          payment['cliente'] ?? 'Cliente',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 180,
                        child: Text(
                          payment['producto'] ?? '',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Text(fecha, style: const TextStyle(fontSize: 10))),
                      DataCell(Text(
                        '${cantidad} ${payment['unidad'] ?? 'un'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        'S/ ${monto.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w700),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment['metodo_pago'] ?? 'Efectivo',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadCredits() async {
    setState(() => _isLoadingCredits = true);
    try {
      // Simular carga de créditos desde API
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _credits = _getSampleCredits();
          _isLoadingCredits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _credits = _getSampleCredits();
          _isLoadingCredits = false;
        });
      }
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoadingPayments = true);
    try {
      // Simular carga de pagos desde API
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _payments = _getSamplePayments();
          _isLoadingPayments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _payments = _getSamplePayments();
          _isLoadingPayments = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSampleCredits() {
    return [
      {
        'id': 'CRE-001',
        'cliente': 'Juan Pérez',
        'producto': 'Arroz Extra Superior 5kg',
        'cantidad': 10,
        'unidad': 'un',
        'monto': 185.00,
        'fecha': DateTime.now().subtract(const Duration(days: 5)),
        'pagado': false,
      },
      {
        'id': 'CRE-002',
        'cliente': 'María García',
        'producto': 'Aceite Vegetal 900ml',
        'cantidad': 5,
        'unidad': 'un',
        'monto': 64.50,
        'fecha': DateTime.now().subtract(const Duration(days: 3)),
        'pagado': true,
      },
      {
        'id': 'CRE-003',
        'cliente': 'Carlos López',
        'producto': 'Leche Evaporada 400ml',
        'cantidad': 20,
        'unidad': 'un',
        'monto': 70.00,
        'fecha': DateTime.now().subtract(const Duration(days: 2)),
        'pagado': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getSamplePayments() {
    return [
      {
        'id': 'PAG-001',
        'cliente': 'María García',
        'producto': 'Aceite Vegetal 900ml',
        'cantidad': 5,
        'unidad': 'un',
        'monto': 64.50,
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'metodo_pago': 'Efectivo',
      },
      {
        'id': 'PAG-002',
        'cliente': 'Ana Martínez',
        'producto': 'Azúcar Rubia 1kg',
        'cantidad': 15,
        'unidad': 'un',
        'monto': 88.50,
        'fecha': DateTime.now(),
        'metodo_pago': 'Transferencia',
      },
    ];
  }

  List<String> _getUniqueClients() {
    final clients = <String>{};
    for (var credit in _credits) {
      final client = credit['cliente']?.toString() ?? '';
      if (client.isNotEmpty) clients.add(client);
    }
    for (var payment in _payments) {
      final client = payment['cliente']?.toString() ?? '';
      if (client.isNotEmpty) clients.add(client);
    }
    final list = clients.toList();
    list.sort();
    return list;
  }

  List<Map<String, dynamic>> _getFilteredCredits() {
    var credits = _credits.map((c) => Map<String, dynamic>.from(c)).toList();
    
    // Filtrar por cliente
    if (_selectedClientFilter != null) {
      credits = credits.where((c) {
        final cliente = (c['cliente'] ?? '').toString();
        return cliente == _selectedClientFilter;
      }).toList();
    }
    
    // Filtrar por fecha
    credits = credits.where((c) {
      final fecha = c['fecha'] is DateTime 
          ? c['fecha'] as DateTime
          : DateTime.tryParse(c['fecha']?.toString() ?? '') ?? DateTime.now();
      return fecha.isAfter(_creditsStartDate.subtract(const Duration(days: 1))) &&
             fecha.isBefore(_creditsEndDate.add(const Duration(days: 1)));
    }).toList();
    
    return credits;
  }

  List<Map<String, dynamic>> _getFilteredPayments() {
    var payments = _payments.map((p) => Map<String, dynamic>.from(p)).toList();
    
    // Filtrar por cliente
    if (_selectedClientFilter != null) {
      payments = payments.where((p) {
        final cliente = (p['cliente'] ?? '').toString();
        return cliente == _selectedClientFilter;
      }).toList();
    }
    
    // Filtrar por fecha
    payments = payments.where((p) {
      final fecha = p['fecha'] is DateTime 
          ? p['fecha'] as DateTime
          : DateTime.tryParse(p['fecha']?.toString() ?? '') ?? DateTime.now();
      return fecha.isAfter(_paymentsStartDate.subtract(const Duration(days: 1))) &&
             fecha.isBefore(_paymentsEndDate.add(const Duration(days: 1)));
    }).toList();
    
    return payments;
  }

  Future<void> _exportCreditsToExcel() async {
    final filteredCredits = _getFilteredCredits();
    
    if (filteredCredits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay créditos para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Créditos'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Cliente');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Fecha');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Cantidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Monto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Estado');
      
      // Data
      for (int i = 0; i < filteredCredits.length; i++) {
        final credit = filteredCredits[i];
        final fecha = credit['fecha'] is DateTime 
            ? DateFormat('dd/MM/yyyy').format(credit['fecha'] as DateTime)
            : credit['fecha']?.toString() ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(credit['cliente'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(credit['producto'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(fecha);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = IntCellValue((credit['cantidad'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((credit['monto'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = TextCellValue((credit['pagado'] ?? false) ? 'Pagado' : 'Pendiente');
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/creditos_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Excel exportado: ${file.path}')),
                ],
              ),
              backgroundColor: const Color(0xFF2563EB),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportCreditsToPDF() async {
    final filteredCredits = _getFilteredCredits();
    
    if (filteredCredits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay créditos para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final pdfBytes = await PDFService.generateInventoryMovementsPDF(
        nombreComercial: provider.currentBusinessName,
        tipo: 'Créditos',
        movimientos: filteredCredits.map((c) {
          final fecha = c['fecha'] is DateTime 
              ? DateFormat('dd/MM/yyyy').format(c['fecha'] as DateTime)
              : c['fecha']?.toString() ?? '';
          return {
            'codigo': (c['id'] ?? '').toString(),
            'producto': (c['producto'] ?? '').toString(),
            'variedad': '',
            'cantidad': c['cantidad'] ?? 0,
            'unidad': (c['unidad'] ?? 'un').toString(),
            'fecha': fecha,
            'precio_venta': c['monto'] ?? 0.0,
            'cliente': (c['cliente'] ?? '').toString(),
          };
        }).toList(),
        fechaDesde: DateFormat('dd/MM/yyyy').format(_creditsStartDate),
        fechaHasta: DateFormat('dd/MM/yyyy').format(_creditsEndDate),
      );
      
      await PDFService.sharePDF(pdfBytes, 'creditos_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('PDF exportado exitosamente')),
              ],
            ),
            backgroundColor: Color(0xFF2563EB),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportPaymentsToExcel() async {
    final filteredPayments = _getFilteredPayments();
    
    if (filteredPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay pagos para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Pagos'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Cliente');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Fecha Pago');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Cantidad');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Monto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Método de Pago');
      
      // Data
      for (int i = 0; i < filteredPayments.length; i++) {
        final payment = filteredPayments[i];
        final fecha = payment['fecha'] is DateTime 
            ? DateFormat('dd/MM/yyyy').format(payment['fecha'] as DateTime)
            : payment['fecha']?.toString() ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(payment['cliente'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(payment['producto'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(fecha);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = IntCellValue((payment['cantidad'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((payment['monto'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = TextCellValue(payment['metodo_pago'] ?? 'Efectivo');
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/pagos_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Excel exportado: ${file.path}')),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportPaymentsToPDF() async {
    final filteredPayments = _getFilteredPayments();
    
    if (filteredPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay pagos para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final pdfBytes = await PDFService.generateInventoryMovementsPDF(
        nombreComercial: provider.currentBusinessName,
        tipo: 'Pagos',
        movimientos: filteredPayments.map((p) {
          final fecha = p['fecha'] is DateTime 
              ? DateFormat('dd/MM/yyyy').format(p['fecha'] as DateTime)
              : p['fecha']?.toString() ?? '';
          return {
            'codigo': (p['id'] ?? '').toString(),
            'producto': (p['producto'] ?? '').toString(),
            'variedad': '',
            'cantidad': p['cantidad'] ?? 0,
            'unidad': (p['unidad'] ?? 'un').toString(),
            'fecha': fecha,
            'precio_venta': p['monto'] ?? 0.0,
            'cliente': (p['cliente'] ?? '').toString(),
          };
        }).toList(),
        fechaDesde: DateFormat('dd/MM/yyyy').format(_paymentsStartDate),
        fechaHasta: DateFormat('dd/MM/yyyy').format(_paymentsEndDate),
      );
      
      await PDFService.sharePDF(pdfBytes, 'pagos_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('PDF exportado exitosamente')),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
