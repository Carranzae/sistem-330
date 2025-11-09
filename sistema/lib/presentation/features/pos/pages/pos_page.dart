import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';
import '../../inventory/widgets/qr_scanner_page.dart';

/// Punto de Venta (POS) Profesional
class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final List<Map<String, dynamic>> _cart = [];
  double _subtotal = 0.0;
  double _descuento = 0.0;
  double _igv = 0.0;
  double _total = 0.0;
  String _selectedPaymentMethod = 'efectivo';
  String? _selectedCustomer;

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    // Cargar productos después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final products = await ApiService.getProducts(businessId: provider.currentBusinessId);
      
      if (mounted) {
        setState(() {
          _allProducts = products.map((p) => {
            'id': p['id'],
            'nombre': p['nombre'],
            'precio': (p['precio'] ?? 0.0).toDouble(),
            'categoria': p['categoria'] ?? 'Otros',
            'stock': p['stock'] ?? 0,
          }).toList();
          _filteredProducts = _allProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Si falla, usar productos de ejemplo
      if (mounted) {
        setState(() {
          _allProducts = [
            {'id': '1', 'nombre': 'Arroz Extra', 'precio': 18.50, 'categoria': 'Abarrotes', 'stock': 15},
            {'id': '2', 'nombre': 'Aceite Vegetal', 'precio': 12.90, 'categoria': 'Abarrotes', 'stock': 25},
            {'id': '3', 'nombre': 'Leche Evaporada', 'precio': 3.50, 'categoria': 'Lácteos', 'stock': 40},
            {'id': '4', 'nombre': 'Azúcar Rubia', 'precio': 4.20, 'categoria': 'Abarrotes', 'stock': 30},
            {'id': '5', 'nombre': 'Fideos', 'precio': 2.80, 'categoria': 'Abarrotes', 'stock': 50},
          ];
          _filteredProducts = _allProducts;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar productos: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((p) {
          return p['nombre'].toString().toLowerCase().contains(query) ||
                 p['categoria'].toString().toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      // Buscar si ya existe en el carrito
      final existingIndex = _cart.indexWhere((item) => item['id'] == product['id']);
      
      if (existingIndex >= 0) {
        // Incrementar cantidad
        _cart[existingIndex]['cantidad'] = (_cart[existingIndex]['cantidad'] ?? 1) + 1;
      } else {
        // Agregar nuevo item
        _cart.add({
          ...product,
          'cantidad': 1,
        });
      }
      
      _calculateTotals();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      final cantidad = _cart[index]['cantidad'] ?? 1;
      if (cantidad > 1) {
        _cart[index]['cantidad'] = cantidad - 1;
      } else {
        _cart.removeAt(index);
      }
      _calculateTotals();
    });
  }

  void _deleteFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _subtotal = _cart.fold(0.0, (sum, item) {
      return sum + ((item['precio'] ?? 0.0) * (item['cantidad'] ?? 1));
    });
    
    _igv = _subtotal * 0.18;
    _total = _subtotal + _igv - _descuento;
  }

  void _processPayment() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildPaymentDialog(),
    );
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
          child: _buildPOSContent(),
        );
      },
    );
  }

  Widget _buildPOSContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          // Desktop layout
          return Row(
            children: [
              Expanded(flex: 3, child: _buildProductSection()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildCartSection()),
            ],
          );
        } else {
          // Mobile layout
          return Column(
            children: [
              Expanded(
                child: _buildProductSection(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: constraints.maxHeight * 0.45,
                child: _buildCartSection(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildProductSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header con búsqueda
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar producto por nombre o categoría...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón scanner QR
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  onPressed: () => _openQRScanner(),
                  tooltip: 'Escanear QR',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid de productos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth > 900 ? 4 : 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final hasStock = (product['stock'] ?? 0) > 0;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasStock ? () => _addToCart(product) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasStock ? const Color(0xFFE5E7EB) : const Color(0xFFEF4444),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen placeholder
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: hasStock ? const Color(0xFFF3F4F6) : Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 48,
                    color: hasStock ? const Color(0xFF9CA3AF) : Colors.red.shade300,
                  ),
                ),
              ),
              
              // Info del producto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product['nombre'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['categoria'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'S/ ${product['precio'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: hasStock ? const Color(0xFF10B981) : Colors.red.shade600,
                            ),
                          ),
                          if (!hasStock)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Sin stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del carrito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carrito de Venta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_cart.length} productos',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _cart.clear();
                        _calculateTotals();
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          
          // Lista de items
          Expanded(
            child: _cart.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return _buildCartItem(item, index);
                    },
                  ),
          ),
          
          // Totales
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E7EB)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTotalRow('Subtotal', _subtotal, isSecondary: true),
                const SizedBox(height: 6),
                _buildTotalRow('IGV (18%)', _igv, isSecondary: true),
                if (_descuento > 0) ...[
                  const SizedBox(height: 6),
                  _buildTotalRow('Descuento', -_descuento, isDiscount: true),
                ],
                const Divider(height: 16),
                _buildTotalRow('TOTAL', _total, isTotal: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _processPayment,
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text(
                      'Procesar Pago',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final subtotal = (item['precio'] ?? 0.0) * (item['cantidad'] ?? 1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Nombre y precio unitario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nombre'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${item['precio'].toStringAsFixed(2)} c/u',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Controles de cantidad
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => _removeFromCart(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item['cantidad']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _addToCart(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Subtotal y botón eliminar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'S/ ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                onPressed: () => _deleteFromCart(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {
    bool isSecondary = false,
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          'S/ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.w700,
            color: isTotal 
                ? const Color(0xFF10B981)
                : isDiscount
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Carrito vacío',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega productos para comenzar',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Procesar Pago'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'S/ ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Campo opcional de nombre de cliente
                TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Cliente (Opcional)',
                    hintText: 'Ingrese el nombre del cliente',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B7280)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Método de Pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodSelector(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _customerNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _completeSale(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar Pago'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      {'id': 'efectivo', 'label': 'Efectivo', 'icon': Icons.money, 'color': const Color(0xFF10B981)},
      {'id': 'tarjeta', 'label': 'Tarjeta', 'icon': Icons.credit_card, 'color': const Color(0xFF2563EB)},
      {'id': 'yape', 'label': 'Yape', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFFF59E0B)},
      {'id': 'plin', 'label': 'Plin', 'icon': Icons.phone_android, 'color': const Color(0xFF8B5CF6)},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selectedPaymentMethod = method['id'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (method['color'] as Color).withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? method['color'] as Color
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    method['icon'] as IconData,
                    color: isSelected ? method['color'] as Color : const Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    method['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? method['color'] as Color : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }).toList(),
    );
  }

  void _completeSale() async {
    Navigator.pop(context);
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Preparar datos de la venta
      final customerName = _customerNameController.text.trim();
      
      final saleData = {
        'negocio_id': provider.currentBusinessId,
        'cliente_id': _selectedCustomer,
        'cliente_nombre': customerName.isNotEmpty ? customerName : null,
        'productos': _cart.map((item) => {
          'producto_id': item['id'],
          'nombre': item['nombre'],
          'cantidad': item['cantidad'] ?? 1,
          'precio_unitario': item['precio'],
          'subtotal': ((item['precio'] ?? 0.0) * (item['cantidad'] ?? 1)),
        }).toList(),
        'subtotal': _subtotal,
        'impuestos': _igv,
        'descuento': _descuento,
        'total': _total,
        'metodo_pago': _selectedPaymentMethod,
        'estado': 'completada',
      };

      // Registrar venta en backend
      await ApiService.createSale(saleData);
      
      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Venta procesada: S/ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Limpiar carrito y campos
      setState(() {
        _cart.clear();
        _customerNameController.clear();
        _calculateTotals();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error al procesar venta: $e'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onQRScanned: (data) {
            // Buscar producto por ID
            if (data.containsKey('productId')) {
              final product = _allProducts.firstWhere(
                (p) => p['id'] == data['productId'],
                orElse: () => {},
              );
              if (product.isNotEmpty) {
                _addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto agregado: ${product['nombre']}'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
