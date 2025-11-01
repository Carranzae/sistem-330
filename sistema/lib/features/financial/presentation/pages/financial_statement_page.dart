import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/pdf_service.dart';

/// Estado Financiero del Negocio
class FinancialStatementPage extends StatefulWidget {
  const FinancialStatementPage({super.key});

  @override
  State<FinancialStatementPage> createState() => _FinancialStatementPageState();
}

class _FinancialStatementPageState extends State<FinancialStatementPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'semana'; // semana, quincena, mes

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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.2),
                          const Color(0xFF059669).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assessment,
                      size: 30,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado Financiero',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Análisis de ingresos y gastos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón descargar
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    onPressed: () => _downloadReport(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Selector de período
              _buildPeriodSelector(),
              
              const SizedBox(height: 16),
              
              // Rango de fechas
              _buildDateRange(),
            ],
          ),
        ),
        
        // Contenido
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen financiero
                _buildFinancialSummary(),
                const SizedBox(height: 24),
                
                // Gráficos y análisis
                _buildCharts(),
                const SizedBox(height: 24),
                
                // Tabla de ingresos
                _buildIncomeTable(),
                const SizedBox(height: 24),
                
                // Tabla de gastos
                _buildExpensesTable(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodButton('semana', '7 días', Icons.calendar_view_week),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton('quincena', '15 días', Icons.calendar_today),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton('mes', '30 días', Icons.calendar_month),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String period, String label, IconData icon) {
    final isSelected = _selectedPeriod == period;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            _updateDateRange(period);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRange() {
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
        const Icon(Icons.arrow_forward, color: Color(0xFF6B7280)),
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

  Widget _buildFinancialSummary() {
    // Simular datos financieros
    final ingresos = 15750.50;
    final gastos = 8920.30;
    final ganancia = ingresos - gastos;
    final margen = gastos > 0 ? ((ganancia / ingresos) * 100).toStringAsFixed(1) : '0.0';
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Ingresos Totales',
              'S/ ${_formatCurrency(ingresos)}',
              Icons.trending_up,
              const Color(0xFF10B981),
              '+12.5% vs anterior',
            ),
            _buildSummaryCard(
              'Gastos Totales',
              'S/ ${_formatCurrency(gastos)}',
              Icons.trending_down,
              const Color(0xFFEF4444),
              '+8.2% vs anterior',
            ),
            _buildSummaryCard(
              'Ganancia Neta',
              'S/ ${_formatCurrency(ganancia)}',
              Icons.account_balance_wallet,
              const Color(0xFF2563EB),
              'Beneficio real',
            ),
            _buildSummaryCard(
              'Margen de Ganancia',
              '$margen%',
              Icons.percent,
              const Color(0xFF8B5CF6),
              'Porcentaje',
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Ingresos por Día',
                  Icons.show_chart,
                  'Gráfico de barras',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Distribución de Ventas',
                  Icons.pie_chart,
                  'Gráfico circular',
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildChartCard('Ingresos por Día', Icons.show_chart, 'Gráfico de barras'),
              const SizedBox(height: 16),
              _buildChartCard('Distribución de Ventas', Icons.pie_chart, 'Gráfico circular'),
            ],
          );
        }
      },
    );
  }

  Widget _buildChartCard(String title, IconData icon, String placeholder) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    placeholder,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: const Color(0xFF10B981), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Ingresos Detallados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSimpleIncomeTable(),
        ],
      ),
    );
  }

  Widget _buildSimpleIncomeTable() {
    final ingresos = [
      {'fecha': '01/12/2024', 'descripcion': 'Ventas en efectivo', 'monto': 5420.00},
      {'fecha': '02/12/2024', 'descripcion': 'Ventas con tarjeta', 'monto': 3250.00},
      {'fecha': '03/12/2024', 'descripcion': 'Ventas en efectivo', 'monto': 4100.00},
      {'fecha': '04/12/2024', 'descripcion': 'Venta mayorista', 'monto': 2980.50},
    ];
    
    return Column(
      children: ingresos.map((ingreso) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingreso['descripcion'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      ingreso['fecha'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'S/ ${_formatCurrency(ingreso['monto'] as num)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpensesTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.money_off, color: const Color(0xFFEF4444), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Gastos Detallados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSimpleExpensesTable(),
        ],
      ),
    );
  }

  Widget _buildSimpleExpensesTable() {
    final gastos = [
      {'fecha': '01/12/2024', 'descripcion': 'Compra de mercadería', 'monto': 4200.00},
      {'fecha': '02/12/2024', 'descripcion': 'Servicios (luz, agua)', 'monto': 450.30},
      {'fecha': '03/12/2024', 'descripcion': 'Alquiler local', 'monto': 1500.00},
      {'fecha': '04/12/2024', 'descripcion': 'Otros gastos', 'monto': 1770.00},
    ];
    
    return Column(
      children: gastos.map((gasto) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto['descripcion'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      gasto['fecha'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'S/ ${_formatCurrency(gasto['monto'] as num)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _updateDateRange(String period) {
    setState(() {
      final now = DateTime.now();
      _endDate = now;
      
      switch (period) {
        case 'semana':
          _startDate = now.subtract(const Duration(days: 7));
          break;
        case 'quincena':
          _startDate = now.subtract(const Duration(days: 15));
          break;
        case 'mes':
          _startDate = now.subtract(const Duration(days: 30));
          break;
      }
    });
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

  Future<void> _downloadReport() async {
    try {
      // Generar PDF del estado financiero
      final pdfBytes = await _generateFinancialPDF();
      
      // Compartir/Descargar
      await PDFService.sharePDF(
        pdfBytes,
        'estado_financiero_${_selectedPeriod}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado financiero descargado exitosamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateFinancialPDF() async {
    // Obtener datos del negocio
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Calcular datos financieros
    final ingresos = 15750.50;
    final gastos = 8920.30;
    final ganancia = ingresos - gastos;
    final margen = ((ganancia / ingresos) * 100);
    
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Generar PDF
    final pdfBytes = await PDFService.generateFinancialStatementPDF(
      nombreComercial: provider.currentBusinessName,
      ruc: '20123456789', // TODO: Obtener del negocio
      direccion: 'Dirección del negocio', // TODO: Obtener del negocio
      fechaDesde: dateFormat.format(_startDate),
      fechaHasta: dateFormat.format(_endDate),
      ingresosTotales: ingresos,
      gastosTotales: gastos,
      gananciaNeta: ganancia,
      margenGanancia: margen,
      ingresos: [
        {'fecha': '01/12/2024', 'descripcion': 'Ventas en efectivo', 'monto': 5420.00},
        {'fecha': '02/12/2024', 'descripcion': 'Ventas con tarjeta', 'monto': 3250.00},
        {'fecha': '03/12/2024', 'descripcion': 'Ventas en efectivo', 'monto': 4100.00},
        {'fecha': '04/12/2024', 'descripcion': 'Venta mayorista', 'monto': 2980.50},
      ],
      gastos: [
        {'fecha': '01/12/2024', 'descripcion': 'Compra de mercadería', 'monto': 4200.00},
        {'fecha': '02/12/2024', 'descripcion': 'Servicios (luz, agua)', 'monto': 450.30},
        {'fecha': '03/12/2024', 'descripcion': 'Alquiler local', 'monto': 1500.00},
        {'fecha': '04/12/2024', 'descripcion': 'Otros gastos', 'monto': 1770.00},
      ],
    );
    
    return pdfBytes;
  }

  String _formatCurrency(num value) {
    return value.toStringAsFixed(2);
  }
}

