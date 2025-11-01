import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';

/// Historial de Movimientos de Inventario (Entradas y Salidas)
class InventoryMovementsPage extends StatefulWidget {
  const InventoryMovementsPage({super.key});

  @override
  State<InventoryMovementsPage> createState() => _InventoryMovementsPageState();
}

class _InventoryMovementsPageState extends State<InventoryMovementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedType = 'todos'; // todos, entradas, salidas

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.hasBusiness) {
          return const Center(child: CircularProgressIndicator());
        }

        // Nota: No usar MainLayout aquí porque ya está dentro del MainLayout del InventoryPage
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    return Column(
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
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2563EB).withOpacity(0.2),
                          const Color(0xFF10B981).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.swap_horiz,
                      size: 30,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Movimientos de Inventario',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registro de entradas y salidas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón nueva entrada
                  ElevatedButton.icon(
                    onPressed: () => _showNewMovement(type: 'entrada'),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nueva Entrada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Filtros de fecha
              _buildDateFilters(),
            ],
          ),
        ),
        
        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Entradas'),
              Tab(text: 'Salidas'),
            ],
          ),
        ),
        
        // Contenido
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMovementsList(type: 'entrada'),
              _buildMovementsList(type: 'salida'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilters() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectDate(isStart: true),
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
                      dateFormat.format(_startDate),
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
              onTap: () => _selectDate(isStart: false),
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
                      dateFormat.format(_endDate),
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

  Widget _buildMovementsList({required String type}) {
    // Simular movimientos
    final movements = _getSampleMovements(type);

    if (movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'entrada' ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ${type == 'entrada' ? 'entradas' : 'salidas'} registradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final movement = movements[index];
        return _buildMovementCard(movement, type);
      },
    );
  }

  Widget _buildMovementCard(Map<String, dynamic> movement, String type) {
    final isEntry = type == 'entrada';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEntry
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFEF4444).withOpacity(0.3),
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
          onTap: () => _showMovementDetails(movement, type),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isEntry ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEntry ? Icons.add_circle : Icons.remove_circle,
                    color: isEntry ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement['producto'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movement['fecha'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (movement['motivo'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        movement['motivo'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Cantidad
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isEntry ? '+' : '-'}${movement['cantidad']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isEntry ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                  Text(
                    movement['unidad'] ?? 'und',
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

  List<Map<String, dynamic>> _getSampleMovements(String type) {
    if (type == 'entrada') {
      return [
        {
          'id': '1',
          'producto': 'Arroz Extra Superior',
          'cantidad': 50,
          'unidad': 'kg',
          'fecha': '01/12/2024 14:30',
          'motivo': 'Compra a proveedor',
          'proveedor': 'Distribuidora García',
        },
        {
          'id': '2',
          'producto': 'Leche Evaporada',
          'cantidad': 100,
          'unidad': 'un',
          'fecha': '02/12/2024 09:15',
          'motivo': 'Compra a proveedor',
          'proveedor': 'Lácteos del Norte',
        },
      ];
    } else {
      return [
        {
          'id': '1',
          'producto': 'Arroz Extra Superior',
          'cantidad': 25,
          'unidad': 'kg',
          'fecha': '03/12/2024 16:45',
          'motivo': 'Venta',
          'cliente': 'Cliente General',
        },
        {
          'id': '2',
          'producto': 'Aceite Vegetal',
          'cantidad': 15,
          'unidad': 'un',
          'fecha': '04/12/2024 11:20',
          'motivo': 'Venta',
          'cliente': 'Cliente General',
        },
      ];
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showNewMovement({required String type}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva ${type == 'entrada' ? 'Entrada' : 'Salida'}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Formulario de registro de movimiento'),
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

  void _showMovementDetails(Map<String, dynamic> movement, String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalles del Movimiento',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Producto', movement['producto'] ?? ''),
            _buildDetailRow('Cantidad', '${movement['cantidad']} ${movement['unidad']}'),
            _buildDetailRow('Fecha', movement['fecha'] ?? ''),
            if (movement['motivo'] != null)
              _buildDetailRow('Motivo', movement['motivo'] ?? ''),
            if (movement['proveedor'] != null)
              _buildDetailRow('Proveedor', movement['proveedor'] ?? ''),
            if (movement['cliente'] != null)
              _buildDetailRow('Cliente', movement['cliente'] ?? ''),
          ],
        ),
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
            width: 100,
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
}

