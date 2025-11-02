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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    // Simular transacciones del día
    setState(() {
      _transactions.addAll([
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
      ]);

      // Calcular totales
      _totalIn = _transactions
          .where((t) => t['type'] == 'venta')
          .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
      _totalOut = _transactions
          .where((t) => t['type'] == 'egreso')
          .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
      _currentTotal = _initialAmount + _totalIn - _totalOut;
      _difference = 0.00;
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
                    const Expanded(
                      child: Text(
                        'Transacciones del Día',
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
                _transactions.add({
                  'id': DateTime.now().toString(),
                  'type': 'egreso',
                  'description': description,
                  'amount': amount,
                  'method': 'Efectivo',
                  'time': DateFormat('HH:mm').format(DateTime.now()),
                  'timestamp': DateTime.now(),
                });
                _totalOut += amount;
                _currentTotal -= amount;
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
}
