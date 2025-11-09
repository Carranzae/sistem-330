import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import 'package:intl/intl.dart';

/// Módulo de Caja - Gestión completa para Abarrotes y Bodega
class CashPage extends StatefulWidget {
  const CashPage({super.key});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  bool _isCashOpen = true;
  double _initialAmount = 500.00;
  double _currentTotal = 0.00;
  double _totalIn = 0.00;
  double _totalOut = 0.00;
  double _difference = 0.00;
  final List<Map<String, dynamic>> _transactions = [];
  final List<Map<String, dynamic>> _allTransactions = [];
  
  // Filtros
  String? _filterType; // 'venta', 'egreso', null (todos)
  String? _filterMethod; // 'Efectivo', 'Tarjeta', 'Yape', 'Plin', null (todos)
  String _filterTimeRange = 'hoy'; // 'hoy', 'semana', 'mes', 'personalizado'
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  double? _filterMinAmount;
  double? _filterMaxAmount;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    // Simular transacciones del día
    final allTrans = [
      {
        'id': '1',
        'type': 'venta',
        'description': 'Venta POS #001',
        'amount': 85.50,
        'method': 'Efectivo',
        'time': '09:15',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      },
      {
        'id': '2',
        'type': 'venta',
        'description': 'Venta POS #002',
        'amount': 125.00,
        'method': 'Tarjeta',
        'time': '10:30',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '3',
        'type': 'egreso',
        'description': 'Pago a proveedor',
        'amount': 200.00,
        'method': 'Efectivo',
        'time': '11:00',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      },
      {
        'id': '4',
        'type': 'venta',
        'description': 'Venta POS #003',
        'amount': 45.20,
        'method': 'Yape',
        'time': '11:45',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
      },
      {
        'id': '5',
        'type': 'venta',
        'description': 'Venta POS #004',
        'amount': 180.00,
        'method': 'Plin',
        'time': '12:30',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      },
      {
        'id': '6',
        'type': 'egreso',
        'description': 'Compra de insumos',
        'amount': 50.00,
        'method': 'Efectivo',
        'time': '13:00',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      },
    ];

    setState(() {
      _allTransactions.clear();
      _allTransactions.addAll(allTrans);
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(_allTransactions);

    // Filtrar por tipo
    if (_filterType != null) {
      filtered = filtered.where((t) => t['type'] == _filterType).toList();
    }

    // Filtrar por método de pago
    if (_filterMethod != null) {
      filtered = filtered.where((t) => t['method'] == _filterMethod).toList();
    }

    // Filtrar por rango de tiempo
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate = now;

    switch (_filterTimeRange) {
      case 'hoy':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'semana':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'personalizado':
        startDate = _filterStartDate;
        endDate = _filterEndDate ?? now;
        break;
    }

    if (startDate != null) {
      filtered = filtered.where((t) {
        final timestamp = t['timestamp'] as DateTime;
        return timestamp.isAfter(startDate!.subtract(const Duration(seconds: 1))) &&
               timestamp.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filtrar por rango de monto
    if (_filterMinAmount != null) {
      filtered = filtered.where((t) => (t['amount'] as num).toDouble() >= _filterMinAmount!).toList();
    }
    if (_filterMaxAmount != null) {
      filtered = filtered.where((t) => (t['amount'] as num).toDouble() <= _filterMaxAmount!).toList();
    }

    // Actualizar lista y recalcular totales
    _transactions.clear();
    _transactions.addAll(filtered);

    _totalIn = _allTransactions
        .where((t) => t['type'] == 'venta')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
    _totalOut = _allTransactions
        .where((t) => t['type'] == 'egreso')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
    _currentTotal = _initialAmount + _totalIn - _totalOut;
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
          child: SingleChildScrollView(
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
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control de Caja',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gestión de efectivo y transacciones',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isCashOpen
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isCashOpen
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isCashOpen
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isCashOpen ? 'ABIERTA' : 'CERRADA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isCashOpen
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Resumen de caja
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Saldo Inicial',
                              _initialAmount,
                              Icons.arrow_downward,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              'Ingresos',
                              _totalIn,
                              Icons.arrow_upward,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Egresos',
                              _totalOut,
                              Icons.arrow_downward,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              'Saldo Actual',
                              _currentTotal,
                              Icons.account_balance_wallet,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      if (_difference != 0.00) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Diferencia',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              Text(
                                'S/ ${_difference.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Acciones rápidas
                if (_isCashOpen)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _recordEgress,
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Registrar Egreso'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _closeCash,
                          icon: const Icon(Icons.close),
                          label: const Text('Cerrar Caja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F2937),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openCash,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Abrir Caja'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // Transacciones del día
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transacciones del Día',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          if (_hasActiveFilters()) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.filter_alt, size: 14, color: Color(0xFF2563EB)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_transactions.length} de ${_allTransactions.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: const Text('Filtrar'),
                      style: TextButton.styleFrom(
                        foregroundColor: _hasActiveFilters() ? const Color(0xFF2563EB) : null,
                      ),
                    ),
                    if (_hasActiveFilters())
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpiar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de transacciones
                _transactions.isEmpty
                    ? _buildEmptyTransactions()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(_transactions[index]);
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'S/ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isSale = transaction['type'] == 'venta';
    final color = isSale ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSale ? Icons.add_shopping_cart : Icons.payment,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
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
                      transaction['time'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      transaction['method'],
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
          // Monto
          Text(
            '${isSale ? '+' : '-'}S/ ${(transaction['amount'] as num).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las transacciones aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCash() {
    showDialog(
      context: context,
      builder: (context) => _buildOpenCashDialog(),
    );
  }

  Widget _buildOpenCashDialog() {
    final initialAmountController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Abrir Caja'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa el monto inicial en la caja'),
          const SizedBox(height: 16),
          TextField(
            controller: initialAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Saldo Inicial (S/)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            final amount = double.tryParse(initialAmountController.text) ?? 0.00;
            setState(() {
              _isCashOpen = true;
              _initialAmount = amount;
              _currentTotal = amount;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Caja abierta exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Abrir'),
        ),
      ],
    );
  }

  void _closeCash() {
    showDialog(
      context: context,
      builder: (context) => _buildCloseCashDialog(),
    );
  }

  Widget _buildCloseCashDialog() {
    final physicalAmountController = TextEditingController(
      text: _currentTotal.toStringAsFixed(2),
    );

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Cerrar Caja'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCloseSummaryRow('Saldo Inicial', _initialAmount),
                _buildCloseSummaryRow('Total Ingresos', _totalIn, isPositive: true),
                _buildCloseSummaryRow('Total Egresos', _totalOut, isPositive: false),
                const Divider(height: 32),
                _buildCloseSummaryRow('Saldo Esperado', _currentTotal, isTotal: true),
                const SizedBox(height: 16),
                TextField(
                  controller: physicalAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Dinero Físico Contado (S/)',
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    final physical = double.tryParse(value) ?? 0.00;
                    final diff = _currentTotal - physical;
                    setDialogState(() {
                      _difference = diff;
                    });
                  },
                ),
                if (_difference != 0.00) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _difference > 0 ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _difference > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                          color: _difference > 0 ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Diferencia: S/ ${_difference.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _difference > 0 ? Colors.red.shade900 : Colors.green.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                setState(() {
                  _isCashOpen = false;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _difference == 0.00
                          ? 'Caja cerrada correctamente'
                          : 'Caja cerrada con diferencia de S/ ${_difference.abs().toStringAsFixed(2)}',
                    ),
                    backgroundColor: _difference == 0.00 ? Colors.green : Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Caja'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloseSummaryRow(
    String label,
    double amount, {
    bool isPositive = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}S/ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w700,
              color: isTotal
                  ? Colors.blue.shade900
                  : isPositive
                      ? Colors.green.shade700
                      : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _recordEgress() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Egreso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto (S/)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              final description = descriptionController.text;
              final amount = double.tryParse(amountController.text) ?? 0.00;

              if (description.isEmpty || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                final newTransaction = {
                  'id': DateTime.now().toString(),
                  'type': 'egreso',
                  'description': description,
                  'amount': amount,
                  'method': 'Efectivo',
                  'time': DateFormat('HH:mm').format(DateTime.now()),
                  'timestamp': DateTime.now(),
                };
                _allTransactions.add(newTransaction);
                _applyFilters();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Egreso registrado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _filterType != null ||
           _filterMethod != null ||
           _filterTimeRange != 'hoy' ||
           _filterMinAmount != null ||
           _filterMaxAmount != null;
  }

  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterMethod = null;
      _filterTimeRange = 'hoy';
      _filterStartDate = null;
      _filterEndDate = null;
      _filterMinAmount = null;
      _filterMaxAmount = null;
      _applyFilters();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildFilterDialog(),
    );
  }

  Widget _buildFilterDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.filter_list, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text('Filtrar Transacciones'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro por tipo
                const Text(
                  'Tipo de Transacción',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Todas',
                      selected: _filterType == null,
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterType = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Ventas',
                      selected: _filterType == 'venta',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterType = selected ? 'venta' : null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Egresos',
                      selected: _filterType == 'egreso',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterType = selected ? 'egreso' : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Filtro por método de pago
                const Text(
                  'Método de Pago',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Todos',
                      selected: _filterMethod == null,
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterMethod = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Efectivo',
                      selected: _filterMethod == 'Efectivo',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterMethod = selected ? 'Efectivo' : null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Tarjeta',
                      selected: _filterMethod == 'Tarjeta',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterMethod = selected ? 'Tarjeta' : null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Yape',
                      selected: _filterMethod == 'Yape',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterMethod = selected ? 'Yape' : null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Plin',
                      selected: _filterMethod == 'Plin',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterMethod = selected ? 'Plin' : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Filtro por rango de tiempo
                const Text(
                  'Rango de Tiempo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Hoy',
                      selected: _filterTimeRange == 'hoy',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterTimeRange = 'hoy';
                          _filterStartDate = null;
                          _filterEndDate = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Esta Semana',
                      selected: _filterTimeRange == 'semana',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterTimeRange = 'semana';
                          _filterStartDate = null;
                          _filterEndDate = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Este Mes',
                      selected: _filterTimeRange == 'mes',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterTimeRange = 'mes';
                          _filterStartDate = null;
                          _filterEndDate = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Personalizado',
                      selected: _filterTimeRange == 'personalizado',
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterTimeRange = selected ? 'personalizado' : 'hoy';
                        });
                      },
                    ),
                  ],
                ),
                
                // Fechas personalizadas
                if (_filterTimeRange == 'personalizado') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _filterStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                _filterStartDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _filterStartDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_filterStartDate!)
                                      : 'Desde',
                                  style: TextStyle(
                                    color: _filterStartDate != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('a'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _filterEndDate ?? DateTime.now(),
                              firstDate: _filterStartDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                _filterEndDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _filterEndDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_filterEndDate!)
                                      : 'Hasta',
                                  style: TextStyle(
                                    color: _filterEndDate != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Filtro por rango de monto
                const Text(
                  'Rango de Monto (Opcional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Monto Mínimo',
                          prefixText: 'S/ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            _filterMinAmount = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('a'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Monto Máximo',
                          prefixText: 'S/ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            _filterMaxAmount = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Limpiar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _applyFilters();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Filtros aplicados: ${_transactions.length} transacciones encontradas',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Aplicar Filtros'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF2563EB).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2563EB),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF2563EB) : Colors.grey[700],
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
