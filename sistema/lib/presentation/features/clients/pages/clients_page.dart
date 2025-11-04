import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

/// Módulo de Clientes - Gestión completa para Abarrotes y Bodega
class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'todos'; // todos, con_credito, morosos
  final List<Map<String, dynamic>> _allClients = [];

  @override
  void initState() {
    super.initState();
    _loadSampleClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSampleClients() {
    // Simular clientes para demostración
    setState(() {
      _allClients.addAll([
        {
          'id': '1',
          'nombre_completo': 'Juan Pérez García',
          'tipo_documento': 'DNI',
          'numero_documento': '12345678',
          'telefono': '987654321',
          'email': 'juan.perez@email.com',
          'direccion': 'Av. Ejemplo 123',
          'estado_crediticio': 'Bueno',
          'limite_credito': 500.00,
          'deuda_actual': 0.00,
          'total_compras': 1250.50,
          'ultima_compra': '15/01/2024',
        },
        {
          'id': '2',
          'nombre_completo': 'María García López',
          'tipo_documento': 'DNI',
          'numero_documento': '87654321',
          'telefono': '912345678',
          'email': 'maria.garcia@email.com',
          'direccion': 'Jr. Demostración 456',
          'estado_crediticio': 'Regular',
          'limite_credito': 300.00,
          'deuda_actual': 150.00,
          'dias_mora': 5,
          'total_compras': 850.30,
          'ultima_compra': '18/01/2024',
        },
        {
          'id': '3',
          'nombre_completo': 'Carlos López Ruiz',
          'tipo_documento': 'DNI',
          'numero_documento': '11223344',
          'telefono': '945678901',
          'email': 'carlos.lopez@email.com',
          'direccion': 'Calle Principal 789',
          'estado_crediticio': 'Moroso',
          'limite_credito': 800.00,
          'deuda_actual': 1200.00,
          'dias_mora': 45,
          'total_compras': 2400.00,
          'ultima_compra': '05/12/2023',
        },
      ]);
    });
  }

  List<Map<String, dynamic>> _getFilteredClients() {
    final query = _searchController.text.toLowerCase();
    var filtered = _allClients;

    // Filtro por estado crediticio
    if (_selectedFilter != 'todos') {
      filtered = filtered.where((c) {
        if (_selectedFilter == 'con_credito') {
          return (c['deuda_actual'] ?? 0.0) > 0;
        } else if (_selectedFilter == 'morosos') {
          return c['estado_crediticio'] == 'Moroso';
        }
        return true;
      }).toList();
    }

    // Búsqueda por nombre o DNI
    if (query.isNotEmpty) {
      filtered = filtered.where((c) {
        return c['nombre_completo'].toString().toLowerCase().contains(query) ||
               c['numero_documento'].toString().contains(query);
      }).toList();
    }

    return filtered;
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
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                ),
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
                                'Clientes',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_allClients.length} clientes registrados',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón agregar
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showAddClientDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Nuevo Cliente',
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
                    const SizedBox(height: 20),
                    // Búsqueda
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o DNI...',
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filtros
                    _buildFilters(),
                  ],
                ),
              ),

              // Lista de clientes
              Expanded(
                child: _getFilteredClients().isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          // TODO: Refrescar datos
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _getFilteredClients().length,
                          itemBuilder: (context, index) {
                            final client = _getFilteredClients()[index];
                            return _buildClientCard(client);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'label': 'Todos', 'value': 'todos', 'count': _allClients.length},
      {
        'label': 'Con Crédito',
        'value': 'con_credito',
        'count': _allClients.where((c) => (c['deuda_actual'] ?? 0.0) > 0).length
      },
      {
        'label': 'Morosos',
        'value': 'morosos',
        'count': _allClients.where((c) => c['estado_crediticio'] == 'Moroso').length
      },
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
              label: Text('${filter['label']} (${filter['count']})'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter['value'] as String);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade50,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? Colors.blue : const Color(0xFFE5E7EB),
                width: isSelected ? 1.5 : 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final creditStatus = client['estado_crediticio'];
    final statusColor = _getCreditStatusColor(creditStatus);
    final hasDebt = (client['deuda_actual'] ?? 0.0) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: creditStatus == 'Moroso' ? Colors.red.shade200 : const Color(0xFFE5E7EB),
          width: creditStatus == 'Moroso' ? 2 : 1,
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
          onTap: () => _showClientDetails(client),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      radius: 28,
                      child: Icon(
                        Icons.person,
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client['nombre_completo'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.credit_card, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${client['tipo_documento']}: ${client['numero_documento']}',
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
                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        creditStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Detalles adicionales
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.phone,
                        client['telefono'],
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.attach_money,
                        'Total: S/ ${client['total_compras'].toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                if (hasDebt) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deuda: S/ ${client['deuda_actual'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              if (client['dias_mora'] != null)
                                Text(
                                  '${client['dias_mora']} días de mora',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (client['estado_crediticio'] == 'Moroso')
                          TextButton.icon(
                            onPressed: () => _registerPayment(client),
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text('Cobrar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getCreditStatusColor(String status) {
    switch (status) {
      case 'Bueno':
        return Colors.green;
      case 'Regular':
        return Colors.orange;
      case 'Moroso':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay clientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer cliente',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddClientDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Cliente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Formulario de registro de cliente'),
              SizedBox(height: 16),
              Text(
                'Esta función estará disponible en la próxima actualización',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cliente agregado (simulado)')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showClientDetails(Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildClientDetailsSheet(client),
    );
  }

  Widget _buildClientDetailsSheet(Map<String, dynamic> client) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
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
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getCreditStatusColor(client['estado_crediticio']).withOpacity(0.1),
                        radius: 32,
                        child: Icon(
                          Icons.person,
                          color: _getCreditStatusColor(client['estado_crediticio']),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client['nombre_completo'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCreditStatusColor(client['estado_crediticio']).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                client['estado_crediticio'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getCreditStatusColor(client['estado_crediticio']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Información de contacto
                  const Text(
                    'Información de Contacto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Documento', '${client['tipo_documento']}: ${client['numero_documento']}'),
                  _buildDetailRow('Teléfono', client['telefono']),
                  _buildDetailRow('Email', client['email'] ?? 'No registrado'),
                  _buildDetailRow('Dirección', client['direccion']),
                  const SizedBox(height: 24),
                  // Historial financiero
                  const Text(
                    'Historial Financiero',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Límite de Crédito'),
                            Text(
                              'S/ ${client['limite_credito'].toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Deuda Actual'),
                            Text(
                              'S/ ${client['deuda_actual'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Compras'),
                            Text(
                              'S/ ${client['total_compras'].toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Última Compra'),
                            Text(
                              client['ultima_compra'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Acciones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showPurchaseHistory(client);
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('Ver Historial'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _registerPayment(client);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Registrar Pago'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
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
      padding: const EdgeInsets.only(bottom: 12),
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

  void _registerPayment(Map<String, dynamic> client) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirigiendo a registro de pago para ${client['nombre_completo']}'),
      ),
    );
    // TODO: Navegar a módulo de créditos
  }

  void _showPurchaseHistory(Map<String, dynamic> client) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mostrando historial de ${client['nombre_completo']}'),
      ),
    );
    // TODO: Mostrar historial de compras
  }
}
