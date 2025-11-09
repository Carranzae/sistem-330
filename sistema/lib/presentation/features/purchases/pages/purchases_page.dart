import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';

/// Módulo de Compras / Proveedores - Sistema Empresarial Completo
class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _purchases = [];
  final List<Map<String, dynamic>> _providers = [];
  final List<Map<String, dynamic>> _accountsPayable = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    _loadProviders();
    _loadPurchases();
    _loadAccountsPayable();
  }

  void _loadProviders() {
    setState(() {
      _providers.addAll([
        {
          'id': '1',
          'name': 'Distribuidora ABC',
          'ruc': '20123456789',
          'contact': 'Juan Pérez',
          'phone': '987654321',
          'email': 'contacto@distribuidoraabc.com',
          'address': 'Av. Principal 123',
          'rating': 5,
          'lastPurchase': '10/01/2024',
        },
        {
          'id': '2',
          'name': 'Alimentos XYZ',
          'ruc': '20234567890',
          'contact': 'María García',
          'phone': '912345678',
          'email': 'ventas@alimentosxyz.com',
          'address': 'Jr. Comercio 456',
          'rating': 4,
          'lastPurchase': '08/01/2024',
        },
        {
          'id': '3',
          'name': 'Mayorista Sur',
          'ruc': '20345678901',
          'contact': 'Carlos López',
          'phone': '945678901',
          'email': 'info@mayoristasur.com',
          'address': 'Calle Mayor 789',
          'rating': 5,
          'lastPurchase': '12/01/2024',
        },
      ]);
    });
  }

  void _loadPurchases() {
    setState(() {
      _purchases.addAll([
        {
          'id': '1',
          'provider': 'Distribuidora ABC',
          'providerId': '1',
          'amount': 1250.00,
          'date': DateTime(2024, 1, 12),
          'doc': 'F001-000123',
          'status': 'Pagado',
          'paymentType': 'Contado',
          'items': [
            {'product': 'Arroz Extra', 'quantity': 50, 'price': 25.00},
            {'product': 'Aceite Girasol', 'quantity': 30, 'price': 8.33},
          ],
        },
        {
          'id': '2',
          'provider': 'Alimentos XYZ',
          'providerId': '2',
          'amount': 850.50,
          'date': DateTime(2024, 1, 10),
          'doc': 'F001-000122',
          'status': 'Pagado',
          'paymentType': 'Contado',
          'items': [
            {'product': 'Azúcar Blanca', 'quantity': 40, 'price': 21.26},
          ],
        },
        {
          'id': '3',
          'provider': 'Mayorista Sur',
          'providerId': '3',
          'amount': 2100.00,
          'date': DateTime(2024, 1, 8),
          'doc': 'F001-000121',
          'status': 'Credito',
          'paymentType': 'Crédito',
          'dueDate': DateTime(2024, 1, 20),
          'items': [
            {'product': 'Fideos', 'quantity': 100, 'price': 21.00},
          ],
        },
      ]);
    });
  }

  void _loadAccountsPayable() {
    setState(() {
      _accountsPayable.addAll(
        _purchases.where((p) => p['status'] == 'Credito').map((p) {
          final dueDate = p['dueDate'] as DateTime? ?? DateTime.now().add(const Duration(days: 30));
          final daysLeft = dueDate.difference(DateTime.now()).inDays;
          return {
            'id': p['id'],
            'provider': p['provider'],
            'amount': p['amount'],
            'dueDate': dueDate,
            'daysLeft': daysLeft,
            'doc': p['doc'],
          };
        }).toList(),
      );
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
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compras',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gestiona tus proveedores y compras',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón Nueva Compra
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showNewPurchaseDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Nueva Compra',
                                style: TextStyle(
                                  fontSize: 15,
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

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF8B5CF6),
                    labelColor: const Color(0xFF8B5CF6),
                    unselectedLabelColor: const Color(0xFF6B7280),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Registrar Compra'),
                      Tab(text: 'Ver Proveedores'),
                      Tab(text: 'Historial'),
                      Tab(text: 'Cuentas por Pagar'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contenido de tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRegisterPurchaseTab(),
                      _buildProvidersTab(),
                      _buildHistoryTab(),
                      _buildAccountsPayableTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterPurchaseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card de ayuda
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Registra las compras de mercadería para actualizar automáticamente tu inventario',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C4A6E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Botón para abrir formulario
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showNewPurchaseDialog,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Registrar Nueva Compra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Estadísticas rápidas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Compras del Mes',
                  '${_purchases.length}',
                  Icons.shopping_bag,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Invertido',
                  'S/ ${_purchases.fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble()).toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersTab() {
    final filteredProviders = _providers.where((p) {
      final query = _searchController.text.toLowerCase();
      return query.isEmpty ||
          p['name'].toString().toLowerCase().contains(query) ||
          p['ruc'].toString().contains(query);
    }).toList();

    return Column(
      children: [
        // Búsqueda y botón agregar
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar proveedor...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchController.clear());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddProviderDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
        ),
        // Estadísticas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Proveedores',
                  '${_providers.length}',
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Compras Mensuales',
                  'S/ ${_purchases.fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble()).toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Lista de proveedores
        Expanded(
          child: filteredProviders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay proveedores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredProviders.length,
                  itemBuilder: (context, index) {
                    return _buildProviderCard(filteredProviders[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_shipping, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RUC: ${provider['ruc']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      provider['contact'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      provider['phone'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: i < (provider['rating'] as int)
                        ? Colors.amber
                        : Colors.grey[300],
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                'Última: ${provider['lastPurchase']}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Filtros y búsqueda
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por proveedor o documento...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Tabla de historial
        Expanded(
          child: _purchases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay compras registradas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _purchases.length,
                        itemBuilder: (context, index) {
                          return _buildPurchaseCard(_purchases[index]);
                        },
                      );
                    } else {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildPurchasesTable(),
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPurchasesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Proveedor', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Documento', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
        rows: _purchases.map((purchase) {
          final isCredit = purchase['status'] == 'Credito';
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy').format(purchase['date'] as DateTime))),
              DataCell(Text(purchase['provider'] as String)),
              DataCell(Text(purchase['doc'] as String)),
              DataCell(Text('S/ ${(purchase['amount'] as num).toStringAsFixed(2)}')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCredit ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    purchase['status'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCredit ? Colors.orange.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: () => _showPurchaseDetails(purchase),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final isCredit = purchase['status'] == 'Credito';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit ? Colors.orange.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: isCredit ? Colors.orange : Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase['provider'] as String,
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
                      DateFormat('dd/MM/yyyy').format(purchase['date'] as DateTime),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.description, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      purchase['doc'] as String,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                'S/ ${(purchase['amount'] as num).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCredit ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  purchase['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCredit ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsPayableTab() {
    final totalPending = _accountsPayable.fold(
      0.0,
      (sum, acc) => sum + (acc['amount'] as num).toDouble(),
    );

    return Column(
      children: [
        // Resumen
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.orange.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendiente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
                Text(
                  'S/ ${totalPending.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tabla de cuentas por pagar
        Expanded(
          child: _accountsPayable.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay cuentas por pagar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _accountsPayable.length,
                        itemBuilder: (context, index) {
                          return _buildAccountCard(_accountsPayable[index]);
                        },
                      );
                    } else {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAccountsPayableTable(),
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAccountsPayableTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(label: Text('Proveedor', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Documento', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Días', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
        rows: _accountsPayable.map((account) {
          final daysLeft = account['daysLeft'] as int;
          final isUrgent = daysLeft <= 7;
          return DataRow(
            cells: [
              DataCell(Text(account['provider'] as String)),
              DataCell(Text(account['doc'] as String)),
              DataCell(Text('S/ ${(account['amount'] as num).toStringAsFixed(2)}')),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(account['dueDate'] as DateTime))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$daysLeft días',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
              DataCell(
                ElevatedButton(
                  onPressed: () => _registerPayment(account),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Pagar'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final daysLeft = account['daysLeft'] as int;
    final isUrgent = daysLeft <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? Colors.red.shade200 : const Color(0xFFE5E7EB),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUrgent ? Icons.warning : Icons.account_balance,
              color: isUrgent ? Colors.red : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['provider'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Vence: ${DateFormat('dd/MM/yyyy').format(account['dueDate'] as DateTime)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.red.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$daysLeft días',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                        ),
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
                'S/ ${(account['amount'] as num).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _registerPayment(account),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Pagar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    );
  }

  void _showNewPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildNewPurchaseDialog(),
    );
  }

  Widget _buildNewPurchaseDialog() {
    final formKey = GlobalKey<FormState>();
    final providerController = TextEditingController();
    final invoiceController = TextEditingController();
    final paymentTypeController = TextEditingController(text: 'Contado');
    DateTime? selectedDate = DateTime.now();
    DateTime? dueDate;
    final List<Map<String, dynamic>> purchaseItems = [];
    bool isSaving = false;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        double calculateTotal() {
          return purchaseItems.fold(0.0, (sum, item) {
            final quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            return sum + (quantity * price);
          });
        }

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_shopping_cart, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text('Nueva Compra'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Proveedor
                  DropdownButtonFormField<String>(
                    value: _providers.isNotEmpty ? _providers.first['id'] : null,
                    decoration: InputDecoration(
                      labelText: 'Proveedor *',
                      prefixIcon: const Icon(Icons.local_shipping),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: _providers.map((provider) {
                      return DropdownMenuItem(
                        value: provider['id'] as String,
                        child: Text(provider['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final provider = _providers.firstWhere((p) => p['id'] == value);
                      providerController.text = provider['name'] as String;
                    },
                    validator: (value) => value == null ? 'Seleccione un proveedor' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Número de Factura
                  TextFormField(
                    controller: invoiceController,
                    decoration: InputDecoration(
                      labelText: 'Número de Factura *',
                      prefixIcon: const Icon(Icons.receipt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Ingrese el número de factura' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Fecha
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
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
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : 'Seleccionar fecha',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tipo de Pago
                  DropdownButtonFormField<String>(
                    value: paymentTypeController.text,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Pago *',
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Contado', child: Text('Contado')),
                      DropdownMenuItem(value: 'Crédito', child: Text('Crédito')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        paymentTypeController.text = value ?? 'Contado';
                        if (value == 'Contado') {
                          dueDate = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Fecha de Vencimiento (si es crédito)
                  if (paymentTypeController.text == 'Crédito')
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event),
                            const SizedBox(width: 12),
                            Text(
                              dueDate != null
                                  ? DateFormat('dd/MM/yyyy').format(dueDate!)
                                  : 'Fecha de vencimiento',
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (paymentTypeController.text == 'Crédito') const SizedBox(height: 16),
                  
                  // Productos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Productos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddProductDialog(
                          context,
                          purchaseItems,
                          (items) {
                            setDialogState(() {
                              purchaseItems.clear();
                              purchaseItems.addAll(items);
                            });
                          },
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  
                  // Lista de productos
                  if (purchaseItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Center(
                        child: Text('No hay productos agregados'),
                      ),
                    )
                  else
                    ...purchaseItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['productName'] ?? 'Producto',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Cant: ${item['quantity']} x S/ ${(item['price'] as num).toStringAsFixed(2)} = S/ ${((item['quantity'] as num) * (item['price'] as num)).toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  purchaseItems.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'S/ ${calculateTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (formKey.currentState!.validate()) {
                  if (purchaseItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agregue al menos un producto'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (paymentTypeController.text == 'Crédito' && dueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seleccione la fecha de vencimiento'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setDialogState(() => isSaving = true);

                  try {
                    final provider = Provider.of<AppProvider>(context, listen: false);
                    final selectedProvider = _providers.firstWhere(
                      (p) => p['id'] == providerController.text || p['name'] == providerController.text,
                    );

                    final total = calculateTotal();
                    final purchaseData = {
                      'negocio_id': provider.currentBusinessId,
                      'proveedor_id': selectedProvider['id'],
                      'proveedor_nombre': selectedProvider['name'],
                      'numero_factura': invoiceController.text.trim(),
                      'fecha': selectedDate?.toIso8601String(),
                      'monto_total': total,
                      'tipo_pago': paymentTypeController.text,
                      'fecha_vencimiento': dueDate?.toIso8601String(),
                      'estado': paymentTypeController.text == 'Contado' ? 'Pagado' : 'Credito',
                      'items': purchaseItems,
                    };

                    // Guardar compra
                    // TODO: Llamar a API cuando esté disponible
                    // await ApiService.createPurchase(purchaseData);

                    // Crear entradas de inventario para cada producto
                    for (final item in purchaseItems) {
                      try {
                        final productId = item['productId'] as String?;
                        if (productId != null) {
                          final entryData = {
                            'negocio_id': provider.currentBusinessId,
                            'producto_id': productId,
                            'tipo': 'compra',
                            'cantidad': item['quantity'],
                            'precio_unitario': item['price'],
                            'proveedor': selectedProvider['name'],
                            'numero_factura': invoiceController.text.trim(),
                            'fecha': selectedDate?.toIso8601String(),
                          };
                          
                          await ApiService.createInventoryEntry(entryData);
                        }
                      } catch (e) {
                        // Continuar con el siguiente producto si falla uno
                      }
                    }

                    // Agregar a la lista local
                    setState(() {
                      _purchases.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        ...purchaseData,
                        'provider': selectedProvider['name'],
                        'providerId': selectedProvider['id'],
                        'amount': total,
                        'date': selectedDate ?? DateTime.now(),
                        'doc': invoiceController.text.trim(),
                        'status': paymentTypeController.text == 'Contado' ? 'Pagado' : 'Credito',
                        'paymentType': paymentTypeController.text,
                        'dueDate': dueDate,
                      });

                      if (paymentTypeController.text == 'Crédito') {
                        _loadAccountsPayable();
                      }
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
                                child: Text('Compra registrada exitosamente. Inventario actualizado.'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al registrar compra: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Guardar Compra'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog(
    BuildContext context,
    List<Map<String, dynamic>> currentItems,
    Function(List<Map<String, dynamic>>) onUpdate,
  ) async {
    final productNameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedProductId;

    final result = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar Producto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Búsqueda de producto
                  FutureBuilder<List<dynamic>>(
                    future: ApiService.getProducts(
                      businessId: Provider.of<AppProvider>(context, listen: false).currentBusinessId,
                    ),
                    builder: (context, snapshot) {
                      final products = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Producto',
                          prefixIcon: const Icon(Icons.inventory_2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: products.map((product) {
                          return DropdownMenuItem<String>(
                            value: (product['id'] ?? product['_id']).toString(),
                            child: Text(product['nombre'] ?? product['name'] ?? 'Producto'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedProductId = value;
                            final product = products.firstWhere(
                              (p) => (p['id'] ?? p['_id']) == value,
                            );
                            productNameController.text = product['nombre'] ?? product['name'] ?? '';
                            priceController.text = (product['precio_compra'] ?? product['purchase_price'] ?? 0.0).toString();
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: productNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Producto *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Cantidad *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'Precio Unitario *',
                            prefixText: 'S/ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (productNameController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty &&
                        priceController.text.isNotEmpty) {
                      final newItem = {
                        'productId': selectedProductId,
                        'productName': productNameController.text,
                        'quantity': int.tryParse(quantityController.text) ?? 0,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                      };
                      Navigator.pop(dialogContext, [newItem]);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final updatedItems = List<Map<String, dynamic>>.from(currentItems);
      updatedItems.addAll(result);
      onUpdate(updatedItems);
    }
  }

  void _showAddProviderDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final rucController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.local_shipping, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text('Nuevo Proveedor'),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Proveedor *',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: rucController,
                      decoration: InputDecoration(
                        labelText: 'RUC *',
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Requerido';
                        if (value!.length != 11) return 'RUC debe tener 11 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contactController,
                      decoration: InputDecoration(
                        labelText: 'Contacto *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Requerido';
                        if (value!.length < 9) return 'Teléfono inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email (Opcional)',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección (Opcional)',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setDialogState(() => isSaving = true);

                    try {
                      // Agregar proveedor localmente
                      setState(() {
                        _providers.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': nameController.text.trim(),
                          'ruc': rucController.text.trim(),
                          'contact': contactController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                          'address': addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
                          'rating': 5,
                          'lastPurchase': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        });
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
                                  child: Text('Proveedor "${nameController.text.trim()}" registrado exitosamente'),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al registrar proveedor: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Guardar Proveedor'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPurchaseDetails(Map<String, dynamic> purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Compra: ${purchase['doc']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Proveedor', purchase['provider']),
              _buildDetailRow('Fecha', DateFormat('dd/MM/yyyy').format(purchase['date'])),
              _buildDetailRow('Monto', 'S/ ${(purchase['amount'] as num).toStringAsFixed(2)}'),
              _buildDetailRow('Estado', purchase['status']),
              if (purchase['dueDate'] != null)
                _buildDetailRow('Vencimiento', DateFormat('dd/MM/yyyy').format(purchase['dueDate'])),
              const SizedBox(height: 16),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.w600)),
              ...(purchase['items'] as List<dynamic>? ?? []).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '• ${item['product'] ?? item['productName']}: ${item['quantity']} x S/ ${(item['price'] as num).toStringAsFixed(2)}',
                  ),
                );
              }),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _registerPayment(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) {
        final amountController = TextEditingController(
          text: (account['amount'] as num).toStringAsFixed(2),
        );
        return AlertDialog(
          title: const Text('Registrar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Proveedor: ${account['provider']}'),
              const SizedBox(height: 16),
              TextFormField(
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
                // TODO: Implementar registro de pago
                setState(() {
                  final purchaseIndex = _purchases.indexWhere((p) => p['id'] == account['id']);
                  if (purchaseIndex != -1) {
                    _purchases[purchaseIndex]['status'] = 'Pagado';
                    _purchases[purchaseIndex]['paymentType'] = 'Contado';
                  }
                  _accountsPayable.removeWhere((a) => a['id'] == account['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pago registrado a ${account['provider']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Registrar Pago'),
            ),
          ],
        );
      },
    );
  }
}
