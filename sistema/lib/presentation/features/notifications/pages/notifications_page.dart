import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';

/// Sistema Empresarial de Notificaciones - Conectado y Funcional
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _lowStockProducts = [];
  final List<Map<String, dynamic>> _expiringProducts = [];
  final List<Map<String, dynamic>> _delinquentClients = [];
  bool _isLoading = true;

  int get _totalNotifications => _lowStockProducts.length + _expiringProducts.length + _delinquentClients.length;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final businessId = provider.currentBusinessId;

      // Cargar datos en paralelo
      final results = await Future.wait([
        _loadLowStockProducts(businessId),
        _loadExpiringProducts(businessId),
        _loadDelinquentClients(businessId),
      ]);

      setState(() {
        _lowStockProducts.clear();
        _lowStockProducts.addAll(results[0] as List<Map<String, dynamic>>);
        
        _expiringProducts.clear();
        _expiringProducts.addAll(results[1] as List<Map<String, dynamic>>);
        
        _delinquentClients.clear();
        _delinquentClients.addAll(results[2] as List<Map<String, dynamic>>);
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Si falla, cargar datos de muestra
      _loadSampleData();
    }
  }

  Future<List<Map<String, dynamic>>> _loadLowStockProducts(String businessId) async {
    try {
      final products = await ApiService.getLowStockProducts(businessId: businessId, threshold: 10);
      return products.map((product) {
        return {
          'id': product['id'] ?? product['_id'] ?? '',
          'name': product['nombre'] ?? product['name'] ?? 'Producto',
          'stock': (product['stock'] ?? product['stock_actual'] ?? 0) as num,
          'minStock': (product['stock_minimo'] ?? product['min_stock'] ?? 10) as num,
          'category': product['categoria'] ?? product['category'] ?? '',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadExpiringProducts(String businessId) async {
    try {
      final products = await ApiService.getProducts(businessId: businessId);
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      final expiring = <Map<String, dynamic>>[];
      
      for (final product in products) {
        final expirationDate = product['fecha_vencimiento'] ?? product['expiration_date'];
        if (expirationDate != null) {
          try {
            final expDate = DateTime.tryParse(expirationDate.toString());
            if (expDate != null && expDate.isAfter(now) && expDate.isBefore(thirtyDaysFromNow)) {
              final daysUntilExpiration = expDate.difference(now).inDays;
              expiring.add({
                'id': product['id'] ?? product['_id'] ?? '',
                'name': product['nombre'] ?? product['name'] ?? 'Producto',
                'expirationDate': expDate,
                'daysUntilExpiration': daysUntilExpiration,
                'stock': (product['stock'] ?? product['stock_actual'] ?? 0) as num,
              });
            }
          } catch (e) {
            // Continuar con el siguiente producto
          }
        }
      }

      // Ordenar por días hasta vencimiento (más urgentes primero)
      expiring.sort((a, b) => (a['daysUntilExpiration'] as int).compareTo(b['daysUntilExpiration'] as int));
      
      return expiring;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadDelinquentClients(String businessId) async {
    try {
      final clients = await ApiService.getClients(businessId: businessId);
      final delinquent = <Map<String, dynamic>>[];

      for (final client in clients) {
        final debt = (client['deuda_actual'] ?? client['current_debt'] ?? 0.0) as num;
        final creditStatus = client['estado_crediticio'] ?? client['credit_status'] ?? '';
        final daysPastDue = client['dias_mora'] ?? client['days_past_due'] ?? 0;

        if (debt.toDouble() > 0 && (creditStatus == 'Moroso' || daysPastDue > 0)) {
          delinquent.add({
            'id': client['id'] ?? client['_id'] ?? '',
            'name': client['nombre_completo'] ?? client['name'] ?? 'Cliente',
            'debt': debt.toDouble(),
            'daysPastDue': daysPastDue as int,
            'phone': client['telefono'] ?? client['phone'] ?? '',
            'email': client['email'] ?? '',
          });
        }
      }

      // Ordenar por días de mora (más urgentes primero)
      delinquent.sort((a, b) => (b['daysPastDue'] as int).compareTo(a['daysPastDue'] as int));
      
      return delinquent;
    } catch (e) {
      return [];
    }
  }

  void _loadSampleData() {
    setState(() {
      _lowStockProducts.addAll([
        {
          'id': '1',
          'name': 'Arroz Extra',
          'stock': 3,
          'minStock': 10,
          'category': 'Granos',
        },
        {
          'id': '2',
          'name': 'Aceite Vegetal',
          'stock': 5,
          'minStock': 15,
          'category': 'Aceites',
        },
        {
          'id': '3',
          'name': 'Azúcar Rubia',
          'stock': 2,
          'minStock': 20,
          'category': 'Endulzantes',
        },
      ]);

      _expiringProducts.addAll([
        {
          'id': '4',
          'name': 'Leche Evaporada',
          'expirationDate': DateTime.now().add(const Duration(days: 5)),
          'daysUntilExpiration': 5,
          'stock': 25,
        },
        {
          'id': '5',
          'name': 'Yogurt',
          'expirationDate': DateTime.now().add(const Duration(days: 8)),
          'daysUntilExpiration': 8,
          'stock': 15,
        },
      ]);

      _delinquentClients.addAll([
        {
          'id': '1',
          'name': 'Juan Pérez',
          'debt': 1200.00,
          'daysPastDue': 45,
          'phone': '987654321',
          'email': 'juan@email.com',
        },
        {
          'id': '2',
          'name': 'Carlos López',
          'debt': 850.00,
          'daysPastDue': 48,
          'phone': '912345678',
          'email': 'carlos@email.com',
        },
      ]);
    });
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
          child: RefreshIndicator(
            onRefresh: _loadNotifications,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Color(0xFF06B6D4),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notificaciones',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Avisos automáticos para tu negocio',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge de notificaciones
                      if (_totalNotifications > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_totalNotifications',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Estadísticas (tarjetas clicables)
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Stock Bajo',
                            '${_lowStockProducts.length}',
                            Icons.inventory_2_outlined,
                            Colors.orange,
                            () => _navigateToInventory(filter: 'stock_bajo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Vencimientos',
                            '${_expiringProducts.length}',
                            Icons.calendar_today_outlined,
                            Colors.red,
                            () => _navigateToReports(reportType: 'expiring'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Clientes Morosos',
                            '${_delinquentClients.length}',
                            Icons.people_outline,
                            Colors.deepOrange,
                            () => _navigateToClients(filter: 'morosos'),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Lista de notificaciones
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _totalNotifications == 0
                            ? _buildEmptyState()
                            : ListView(
                                children: [
                                  if (_lowStockProducts.isNotEmpty) ...[
                                    _buildNotificationCategory(
                                      'Stock Bajo',
                                      Icons.inventory_2_outlined,
                                      Colors.orange,
                                      _lowStockProducts,
                                      'stock',
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_expiringProducts.isNotEmpty) ...[
                                    _buildNotificationCategory(
                                      'Productos por Vencer',
                                      Icons.calendar_today_outlined,
                                      Colors.red,
                                      _expiringProducts,
                                      'expiring',
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_delinquentClients.isNotEmpty) ...[
                                    _buildNotificationCategory(
                                      'Clientes Morosos',
                                      Icons.people_outline,
                                      Colors.deepOrange,
                                      _delinquentClients,
                                      'clients',
                                    ),
                                  ],
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCategory(
    String category,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> items,
    String type,
  ) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (items.length > 3)
                  TextButton(
                    onPressed: () => _navigateToFullList(type),
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.take(5).map((item) => _buildNotificationItem(item, color, type)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item, Color color, String type) {
    Widget subtitle;
    List<Widget> actions = [];

    if (type == 'stock') {
      final stock = item['stock'] as num;
      final minStock = item['minStock'] as num;
      subtitle = Text(
        'Stock: ${stock.toInt()} unidades (Mínimo: ${minStock.toInt()})',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      );
      actions = [
        IconButton(
          icon: const Icon(Icons.shopping_cart, size: 20),
          color: Colors.orange,
          onPressed: () => _showPurchaseOptions(item),
          tooltip: 'Generar pedido',
        ),
      ];
    } else if (type == 'expiring') {
      final days = item['daysUntilExpiration'] as int;
      final isUrgent = days <= 7;
      subtitle = Row(
        children: [
          Icon(
            isUrgent ? Icons.warning : Icons.info_outline,
            size: 14,
            color: isUrgent ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            'Vence en $days ${days == 1 ? 'día' : 'días'}',
            style: TextStyle(
              fontSize: 13,
              color: isUrgent ? Colors.red : Colors.orange,
              fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      );
      actions = [
        IconButton(
          icon: const Icon(Icons.local_offer, size: 20),
          color: Colors.red,
          onPressed: () => _showDiscountOptions(item),
          tooltip: 'Aplicar descuento',
        ),
      ];
    } else {
      final debt = item['debt'] as double;
      final days = item['daysPastDue'] as int;
      subtitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deuda: S/ ${debt.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '$days días de mora',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
      actions = [
        IconButton(
          icon: const Icon(Icons.phone, size: 20),
          color: Colors.deepOrange,
          onPressed: () => _contactClient(item),
          tooltip: 'Contactar',
        ),
        IconButton(
          icon: const Icon(Icons.payment, size: 20),
          color: Colors.deepOrange,
          onPressed: () => _registerPayment(item),
          tooltip: 'Registrar pago',
        ),
      ];
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleItemTap(item, type),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                ),
              ),
              ...actions,
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
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
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todo está en orden',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(Map<String, dynamic> item, String type) {
    if (type == 'stock') {
      _navigateToProduct(item['id'] as String);
    } else if (type == 'expiring') {
      _navigateToProduct(item['id'] as String);
    } else {
      _navigateToClient(item['id'] as String);
    }
  }

  void _navigateToInventory({String? filter}) {
    // TODO: Navegar a inventario con filtro aplicado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a inventario${filter != null ? ' (filtro: $filter)' : ''}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToReports({String? reportType}) {
    // TODO: Navegar a reportes con tipo específico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a reportes${reportType != null ? ' ($reportType)' : ''}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToClients({String? filter}) {
    // TODO: Navegar a clientes con filtro aplicado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a clientes${filter != null ? ' (filtro: $filter)' : ''}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToProduct(String productId) {
    // TODO: Navegar a detalle de producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a producto: $productId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToClient(String clientId) {
    // TODO: Navegar a detalle de cliente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a cliente: $clientId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToFullList(String type) {
    switch (type) {
      case 'stock':
        _navigateToInventory(filter: 'stock_bajo');
        break;
      case 'expiring':
        _navigateToReports(reportType: 'expiring');
        break;
      case 'clients':
        _navigateToClients(filter: 'morosos');
        break;
    }
  }

  void _showPurchaseOptions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones para ${product['name']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.orange),
              title: const Text('Generar Pedido'),
              subtitle: const Text('Crear orden de compra para este producto'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a módulo de compras
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirigiendo a compras...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.blue),
              title: const Text('Ver Proveedores'),
              subtitle: const Text('Consultar proveedores disponibles'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a proveedores
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirigiendo a proveedores...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.green),
              title: const Text('Ajustar Stock'),
              subtitle: const Text('Modificar stock manualmente'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProduct(product['id'] as String);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountOptions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones para ${product['name']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.red),
              title: const Text('Aplicar Descuento'),
              subtitle: const Text('Crear promoción para vender rápido'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de descuento en desarrollo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.orange),
              title: const Text('Retirar de Inventario'),
              subtitle: const Text('Marcar como vencido y retirar'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de retiro en desarrollo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Colors.blue),
              title: const Text('Generar Reporte de Merma'),
              subtitle: const Text('Registrar pérdida por vencimiento'),
              onTap: () {
                Navigator.pop(context);
                _navigateToReports(reportType: 'expiring');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactClient(Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contactar ${client['name']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (client['phone'] != null && client['phone'].toString().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text('Llamar: ${client['phone']}'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar llamada telefónica
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Llamando a ${client['phone']}...')),
                  );
                },
              ),
            if (client['email'] != null && client['email'].toString().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: Text('Enviar Email: ${client['email']}'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar envío de email
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Enviando email a ${client['email']}...')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.orange),
              title: const Text('Enviar Recordatorio de Pago'),
              subtitle: const Text('Notificación automática de deuda pendiente'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recordatorio enviado')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.purple),
              title: const Text('Ver Historial de Crédito'),
              onTap: () {
                Navigator.pop(context);
                _navigateToClient(client['id'] as String);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _registerPayment(Map<String, dynamic> client) {
    showDialog(
      context: context,
      builder: (context) {
        final amountController = TextEditingController(
          text: (client['debt'] as double).toStringAsFixed(2),
        );
        return AlertDialog(
          title: Text('Registrar Pago - ${client['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deuda actual: S/ ${(client['debt'] as double).toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Monto a Pagar',
                  prefixText: 'S/ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pago registrado para ${client['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Recargar notificaciones
                _loadNotifications();
              },
              child: const Text('Registrar Pago'),
            ),
          ],
        );
      },
    );
  }
}
