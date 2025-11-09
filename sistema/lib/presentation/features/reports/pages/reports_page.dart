import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/pdf_service.dart';

/// Módulo de Reportes Empresariales - Análisis y estadísticas profesionales
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
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
          child: _buildReportsContent(provider.currentBusinessCategory),
        );
      },
    );
  }

  Widget _buildReportsContent(String category) {
    return SingleChildScrollView(
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
                  Icons.assessment,
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
                      'Reportes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Análisis y estadísticas de tu negocio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Grid de reportes
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.5 : 1.2,
                ),
                itemCount: _getReports(category).length,
                itemBuilder: (context, index) {
                  return _buildReportCard(_getReports(category)[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getReports(String category) {
    return [
      {
        'title': 'Reporte de Ventas',
        'description': 'Análisis de ventas por período',
        'icon': Icons.trending_up,
        'color': const Color(0xFF10B981),
        'onTap': () => _openSalesReport(),
      },
      {
        'title': 'Reporte de Inventario',
        'description': 'Stock, valoración y rotación',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF2563EB),
        'onTap': () => _openInventoryReport(),
      },
      {
        'title': 'Reporte Financiero',
        'description': 'Ganancias, pérdidas y márgenes',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => _openFinancialReport(),
      },
      {
        'title': 'Reporte de Clientes',
        'description': 'Análisis de clientes y créditos',
        'icon': Icons.people,
        'color': const Color(0xFFEC4899),
        'onTap': () => _openClientsReport(),
      },
      if (category == 'abarrotes')
        {
          'title': 'Productos por Vencer',
          'description': 'Alertas de vencimientos',
          'icon': Icons.warning,
          'color': const Color(0xFFEF4444),
          'onTap': () => _openExpiringProductsReport(),
        },
      {
        'title': 'Reporte de Caja',
        'description': 'Arqueo y balance de caja',
        'icon': Icons.receipt,
        'color': const Color(0xFFF59E0B),
        'onTap': () => _openCashReport(),
      },
    ];
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => (report['onTap'] as Function).call(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (report['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    report['icon'] as IconData,
                    color: report['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  report['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    report['description'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _exportReport(report['title'] as String),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Exportar'),
                      style: TextButton.styleFrom(
                        foregroundColor: report['color'] as Color,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
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

  // ==================== NAVEGACIÓN A REPORTES ====================

  void _openSalesReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesReportPage(),
      ),
    );
  }

  void _openInventoryReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryReportPage(),
      ),
    );
  }

  void _openFinancialReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialReportPage(),
      ),
    );
  }

  void _openClientsReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientsReportPage(),
      ),
    );
  }

  void _openExpiringProductsReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpiringProductsReportPage(),
      ),
    );
  }

  void _openCashReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashReportPage(),
      ),
    );
  }

  void _exportReport(String reportTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Abre el reporte para exportar con datos completos'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ==================== REPORTE DE VENTAS ====================

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  List<dynamic> _sales = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final sales = await ApiService.getSales(businessId: provider.currentBusinessId);
      
      // Filtrar por fecha
      final filteredSales = sales.where((sale) {
        final saleDate = sale['fecha'] is DateTime
            ? sale['fecha'] as DateTime
            : DateTime.tryParse(sale['fecha']?.toString() ?? '');
        if (saleDate == null) return false;
        return saleDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
               saleDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      // Calcular estadísticas
      double totalSales = 0;
      int totalTransactions = filteredSales.length;
      Map<String, double> salesByMethod = {};
      Map<String, int> salesByDay = {};

      for (var sale in filteredSales) {
        final total = (sale['total'] ?? 0.0) as num;
        totalSales += total.toDouble();
        
        final method = sale['metodo_pago'] ?? 'efectivo';
        salesByMethod[method] = (salesByMethod[method] ?? 0.0) + total.toDouble();
        
        final date = sale['fecha'] is DateTime
            ? sale['fecha'] as DateTime
            : DateTime.tryParse(sale['fecha']?.toString() ?? '');
        if (date != null) {
          final dayKey = DateFormat('dd/MM').format(date);
          salesByDay[dayKey] = (salesByDay[dayKey] ?? 0) + 1;
        }
      }

      setState(() {
        _sales = filteredSales;
        _stats = {
          'totalSales': totalSales,
          'totalTransactions': totalTransactions,
          'averageSale': totalTransactions > 0 ? totalSales / totalTransactions : 0,
          'salesByMethod': salesByMethod,
          'salesByDay': salesByDay,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ventas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilters(),
                  const SizedBox(height: 24),
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildSalesTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(true),
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
                  Text(DateFormat('dd/MM/yyyy').format(_startDate)),
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
            onTap: () => _selectDate(false),
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
                  Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
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
      _loadSales();
    }
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile
            ? Column(
                children: [
                  _buildStatCard('Total Ventas', 'S/ ${_stats['totalSales']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.green),
                  const SizedBox(height: 12),
                  _buildStatCard('Transacciones', '${_stats['totalTransactions'] ?? 0}', Icons.receipt, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatCard('Promedio', 'S/ ${_stats['averageSale']?.toStringAsFixed(2) ?? '0.00'}', Icons.trending_up, Colors.purple),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildStatCard('Total Ventas', 'S/ ${_stats['totalSales']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Transacciones', '${_stats['totalTransactions'] ?? 0}', Icons.receipt, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Promedio', 'S/ ${_stats['averageSale']?.toStringAsFixed(2) ?? '0.00'}', Icons.trending_up, Colors.purple)),
                ],
              );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    if (_sales.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay ventas en el período seleccionado'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Cliente')),
            DataColumn(label: Text('Productos')),
            DataColumn(label: Text('Método Pago')),
            DataColumn(label: Text('Total')),
          ],
          rows: _sales.map((sale) {
            final fecha = sale['fecha'] is DateTime
                ? DateFormat('dd/MM/yyyy HH:mm').format(sale['fecha'] as DateTime)
                : sale['fecha']?.toString() ?? '';
            final cliente = sale['cliente_nombre'] ?? 'Cliente General';
            final productos = (sale['productos'] as List?)?.length ?? 0;
            final metodo = sale['metodo_pago'] ?? 'efectivo';
            final total = sale['total'] ?? 0.0;

            return DataRow(
              cells: [
                DataCell(Text(fecha)),
                DataCell(Text(cliente)),
                DataCell(Text('$productos productos')),
                DataCell(Text(metodo)),
                DataCell(Text('S/ ${(total as num).toStringAsFixed(2)}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = await PDFService.generateSalesReportPDF(
        sales: _sales,
        stats: _stats,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reporte_ventas_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Ventas'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Fecha');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Cliente');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Productos');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Método Pago');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Total');
      
      // Data
      for (int i = 0; i < _sales.length; i++) {
        final sale = _sales[i];
        final fecha = sale['fecha'] is DateTime
            ? DateFormat('dd/MM/yyyy HH:mm').format(sale['fecha'] as DateTime)
            : sale['fecha']?.toString() ?? '';
        final cliente = sale['cliente_nombre'] ?? 'Cliente General';
        final productos = (sale['productos'] as List?)?.length ?? 0;
        final metodo = sale['metodo_pago'] ?? 'efectivo';
        final total = sale['total'] ?? 0.0;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(fecha);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(cliente);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = IntCellValue(productos);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = TextCellValue(metodo);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((total as num).toDouble());
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/reporte_ventas_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }
}

// ==================== REPORTE DE INVENTARIO ====================

class InventoryReportPage extends StatefulWidget {
  const InventoryReportPage({super.key});

  @override
  State<InventoryReportPage> createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  bool _isLoading = false;
  List<dynamic> _products = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final products = await ApiService.getProducts(businessId: provider.currentBusinessId);
      
      // Calcular estadísticas
      double totalValue = 0;
      int totalProducts = products.length;
      int lowStockCount = 0;
      int outOfStockCount = 0;
      Map<String, int> productsByCategory = {};

      for (var product in products) {
        final stock = (product['stock'] ?? 0) as num;
        final precioCompra = (product['precio_compra'] ?? product['precio'] ?? 0.0) as num;
        totalValue += stock.toDouble() * precioCompra.toDouble();
        
        if (stock == 0) {
          outOfStockCount++;
        } else if (stock < 10) {
          lowStockCount++;
        }
        
        final categoria = product['categoria'] ?? 'Otros';
        productsByCategory[categoria] = (productsByCategory[categoria] ?? 0) + 1;
      }

      setState(() {
        _products = products;
        _stats = {
          'totalValue': totalValue,
          'totalProducts': totalProducts,
          'lowStockCount': lowStockCount,
          'outOfStockCount': outOfStockCount,
          'productsByCategory': productsByCategory,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar inventario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildInventoryTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile
            ? Column(
                children: [
                  _buildStatCard('Valor Total', 'S/ ${_stats['totalValue']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatCard('Total Productos', '${_stats['totalProducts'] ?? 0}', Icons.inventory_2, Colors.green),
                  const SizedBox(height: 12),
                  _buildStatCard('Stock Bajo', '${_stats['lowStockCount'] ?? 0}', Icons.warning, Colors.orange),
                  const SizedBox(height: 12),
                  _buildStatCard('Sin Stock', '${_stats['outOfStockCount'] ?? 0}', Icons.error, Colors.red),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildStatCard('Valor Total', 'S/ ${_stats['totalValue']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Total Productos', '${_stats['totalProducts'] ?? 0}', Icons.inventory_2, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Stock Bajo', '${_stats['lowStockCount'] ?? 0}', Icons.warning, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Sin Stock', '${_stats['outOfStockCount'] ?? 0}', Icons.error, Colors.red)),
                ],
              );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay productos en el inventario'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Producto')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Precio Compra')),
            DataColumn(label: Text('Precio Venta')),
            DataColumn(label: Text('Valor Total')),
          ],
          rows: _products.map((product) {
            final codigo = product['codigo'] ?? product['id'] ?? '';
            final nombre = product['nombre'] ?? '';
            final categoria = product['categoria'] ?? 'Otros';
            final stock = product['stock'] ?? 0;
            final precioCompra = product['precio_compra'] ?? product['precio'] ?? 0.0;
            final precioVenta = product['precio_venta'] ?? product['precio'] ?? 0.0;
            final valorTotal = (stock as num).toDouble() * (precioCompra as num).toDouble();

            return DataRow(
              cells: [
                DataCell(Text(codigo)),
                DataCell(Text(nombre)),
                DataCell(Text(categoria)),
                DataCell(Text('$stock')),
                DataCell(Text('S/ ${(precioCompra as num).toStringAsFixed(2)}')),
                DataCell(Text('S/ ${(precioVenta as num).toStringAsFixed(2)}')),
                DataCell(Text('S/ ${valorTotal.toStringAsFixed(2)}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = await PDFService.generateInventoryReportPDF(
        products: _products,
        stats: _stats,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reporte_inventario_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Inventario'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Código');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Categoría');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Stock');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Precio Compra');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Precio Venta');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = TextCellValue('Valor Total');
      
      // Data
      for (int i = 0; i < _products.length; i++) {
        final product = _products[i];
        final stock = product['stock'] ?? 0;
        final precioCompra = product['precio_compra'] ?? product['precio'] ?? 0.0;
        final precioVenta = product['precio_venta'] ?? product['precio'] ?? 0.0;
        final valorTotal = (stock as num).toDouble() * (precioCompra as num).toDouble();

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(product['codigo'] ?? product['id'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(product['nombre'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(product['categoria'] ?? 'Otros');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = IntCellValue((stock as num).toInt());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((precioCompra as num).toDouble());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = DoubleCellValue((precioVenta as num).toDouble());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = DoubleCellValue(valorTotal);
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/reporte_inventario_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }
}

// ==================== REPORTE FINANCIERO ====================

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({super.key});

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  List<dynamic> _sales = [];
  List<dynamic> _entries = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final sales = await ApiService.getSales(businessId: provider.currentBusinessId);
      final entries = await ApiService.getInventoryEntries(
        businessId: provider.currentBusinessId,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      // Filtrar ventas por fecha
      final filteredSales = sales.where((sale) {
        final saleDate = sale['fecha'] is DateTime
            ? sale['fecha'] as DateTime
            : DateTime.tryParse(sale['fecha']?.toString() ?? '');
        if (saleDate == null) return false;
        return saleDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
               saleDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      // Calcular estadísticas financieras
      double totalRevenue = 0;
      double totalCosts = 0;
      
      for (var sale in filteredSales) {
        totalRevenue += (sale['total'] ?? 0.0) as num;
      }
      
      for (var entry in entries) {
        final cantidad = (entry['cantidad'] ?? 0) as num;
        final precioCompra = (entry['precio_compra'] ?? 0.0) as num;
        totalCosts += cantidad.toDouble() * precioCompra.toDouble();
      }

      final grossProfit = totalRevenue - totalCosts;
      final profitMargin = totalRevenue > 0 ? (grossProfit / totalRevenue * 100) : 0;

      setState(() {
        _sales = filteredSales;
        _entries = entries;
        _stats = {
          'totalRevenue': totalRevenue,
          'totalCosts': totalCosts,
          'grossProfit': grossProfit,
          'profitMargin': profitMargin,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos financieros: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte Financiero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilters(),
                  const SizedBox(height: 24),
                  _buildFinancialStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(true),
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
                  Text(DateFormat('dd/MM/yyyy').format(_startDate)),
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
            onTap: () => _selectDate(false),
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
                  Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
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
      _loadFinancialData();
    }
  }

  Widget _buildFinancialStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile
            ? Column(
                children: [
                  _buildStatCard('Ingresos', 'S/ ${_stats['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}', Icons.trending_up, Colors.green),
                  const SizedBox(height: 12),
                  _buildStatCard('Costos', 'S/ ${_stats['totalCosts']?.toStringAsFixed(2) ?? '0.00'}', Icons.trending_down, Colors.red),
                  const SizedBox(height: 12),
                  _buildStatCard('Ganancia Bruta', 'S/ ${_stats['grossProfit']?.toStringAsFixed(2) ?? '0.00'}', Icons.account_balance_wallet, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatCard('Margen', '${_stats['profitMargin']?.toStringAsFixed(2) ?? '0.00'}%', Icons.percent, Colors.purple),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildStatCard('Ingresos', 'S/ ${_stats['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}', Icons.trending_up, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Costos', 'S/ ${_stats['totalCosts']?.toStringAsFixed(2) ?? '0.00'}', Icons.trending_down, Colors.red)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Ganancia Bruta', 'S/ ${_stats['grossProfit']?.toStringAsFixed(2) ?? '0.00'}', Icons.account_balance_wallet, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Margen', '${_stats['profitMargin']?.toStringAsFixed(2) ?? '0.00'}%', Icons.percent, Colors.purple)),
                ],
              );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = await PDFService.generateFinancialReportPDF(
        stats: _stats,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reporte_financiero_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Financiero'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Concepto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Monto');
      
      // Data
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue('Ingresos Totales');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = DoubleCellValue(_stats['totalRevenue'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = TextCellValue('Costos Totales');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = DoubleCellValue(_stats['totalCosts'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('Ganancia Bruta');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = DoubleCellValue(_stats['grossProfit'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4)).value = TextCellValue('Margen de Ganancia (%)');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value = DoubleCellValue(_stats['profitMargin'] ?? 0.0);
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/reporte_financiero_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }
}

// ==================== REPORTE DE CLIENTES ====================

class ClientsReportPage extends StatefulWidget {
  const ClientsReportPage({super.key});

  @override
  State<ClientsReportPage> createState() => _ClientsReportPageState();
}

class _ClientsReportPageState extends State<ClientsReportPage> {
  bool _isLoading = false;
  List<dynamic> _clients = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final clients = await ApiService.getClients(businessId: provider.currentBusinessId);
      
      // Calcular estadísticas
      int totalClients = clients.length;
      int activeClients = 0;
      double totalCredits = 0;

      for (var client in clients) {
        if (client['activo'] == true) activeClients++;
        totalCredits += (client['credito_pendiente'] ?? 0.0) as num;
      }

      setState(() {
        _clients = clients;
        _stats = {
          'totalClients': totalClients,
          'activeClients': activeClients,
          'totalCredits': totalCredits,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar clientes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildClientsTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile
            ? Column(
                children: [
                  _buildStatCard('Total Clientes', '${_stats['totalClients'] ?? 0}', Icons.people, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatCard('Clientes Activos', '${_stats['activeClients'] ?? 0}', Icons.person, Colors.green),
                  const SizedBox(height: 12),
                  _buildStatCard('Créditos Pendientes', 'S/ ${_stats['totalCredits']?.toStringAsFixed(2) ?? '0.00'}', Icons.credit_card, Colors.orange),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildStatCard('Total Clientes', '${_stats['totalClients'] ?? 0}', Icons.people, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Clientes Activos', '${_stats['activeClients'] ?? 0}', Icons.person, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Créditos Pendientes', 'S/ ${_stats['totalCredits']?.toStringAsFixed(2) ?? '0.00'}', Icons.credit_card, Colors.orange)),
                ],
              );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsTable() {
    if (_clients.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay clientes registrados'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Documento')),
            DataColumn(label: Text('Teléfono')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Crédito')),
            DataColumn(label: Text('Estado')),
          ],
          rows: _clients.map((client) {
            final nombre = client['nombre'] ?? '';
            final documento = client['documento'] ?? '';
            final telefono = client['telefono'] ?? '';
            final email = client['email'] ?? '';
            final credito = client['credito_pendiente'] ?? 0.0;
            final activo = client['activo'] ?? true;

            return DataRow(
              cells: [
                DataCell(Text(nombre)),
                DataCell(Text(documento)),
                DataCell(Text(telefono)),
                DataCell(Text(email)),
                DataCell(Text('S/ ${(credito as num).toStringAsFixed(2)}')),
                DataCell(Text(activo ? 'Activo' : 'Inactivo')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = await PDFService.generateClientsReportPDF(
        clients: _clients,
        stats: _stats,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reporte_clientes_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Clientes'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Nombre');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Documento');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Teléfono');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Email');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Crédito Pendiente');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Estado');
      
      // Data
      for (int i = 0; i < _clients.length; i++) {
        final client = _clients[i];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(client['nombre'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(client['documento'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(client['telefono'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = TextCellValue(client['email'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue((client['credito_pendiente'] ?? 0.0).toDouble());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = TextCellValue((client['activo'] ?? true) ? 'Activo' : 'Inactivo');
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/reporte_clientes_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }
}

// ==================== PRODUCTOS POR VENCER ====================

class ExpiringProductsReportPage extends StatefulWidget {
  const ExpiringProductsReportPage({super.key});

  @override
  State<ExpiringProductsReportPage> createState() => _ExpiringProductsReportPageState();
}

class _ExpiringProductsReportPageState extends State<ExpiringProductsReportPage> {
  bool _isLoading = false;
  List<dynamic> _expiringProducts = [];

  @override
  void initState() {
    super.initState();
    _loadExpiringProducts();
  }

  Future<void> _loadExpiringProducts() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final products = await ApiService.getProducts(businessId: provider.currentBusinessId);
      
      final now = DateTime.now();
      final expiring = products.where((product) {
        if (product['fecha_vencimiento'] == null) return false;
        final fechaVenc = product['fecha_vencimiento'] is DateTime 
            ? product['fecha_vencimiento'] as DateTime
            : DateTime.tryParse(product['fecha_vencimiento'].toString());
        return fechaVenc != null && fechaVenc.isAfter(now) && fechaVenc.isBefore(now.add(const Duration(days: 30)));
      }).toList();

      setState(() {
        _expiringProducts = expiring;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos por Vencer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expiringProducts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay productos próximos a vencer'),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Producto')),
                          DataColumn(label: Text('Categoría')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Fecha Vencimiento')),
                          DataColumn(label: Text('Días Restantes')),
                        ],
                        rows: _expiringProducts.map((product) {
                          final nombre = product['nombre'] ?? '';
                          final categoria = product['categoria'] ?? 'Otros';
                          final stock = product['stock'] ?? 0;
                          final fechaVenc = product['fecha_vencimiento'] is DateTime 
                              ? product['fecha_vencimiento'] as DateTime
                              : DateTime.tryParse(product['fecha_vencimiento'].toString());
                          final diasRestantes = fechaVenc != null 
                              ? fechaVenc.difference(DateTime.now()).inDays
                              : 0;

                          return DataRow(
                            cells: [
                              DataCell(Text(nombre)),
                              DataCell(Text(categoria)),
                              DataCell(Text('$stock')),
                              DataCell(Text(fechaVenc != null ? DateFormat('dd/MM/yyyy').format(fechaVenc) : '')),
                              DataCell(Text('$diasRestantes días', style: TextStyle(color: diasRestantes < 7 ? Colors.red : Colors.orange))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = await PDFService.generateExpiringProductsReportPDF(
        products: _expiringProducts,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/productos_vencer_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Productos por Vencer'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Categoría');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Stock');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Fecha Vencimiento');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Días Restantes');
      
      // Data
      for (int i = 0; i < _expiringProducts.length; i++) {
        final product = _expiringProducts[i];
        final fechaVenc = product['fecha_vencimiento'] is DateTime 
            ? product['fecha_vencimiento'] as DateTime
            : DateTime.tryParse(product['fecha_vencimiento'].toString());
        final diasRestantes = fechaVenc != null 
            ? fechaVenc.difference(DateTime.now()).inDays
            : 0;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(product['nombre'] ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(product['categoria'] ?? 'Otros');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = IntCellValue((product['stock'] ?? 0).toInt());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = TextCellValue(fechaVenc != null ? DateFormat('dd/MM/yyyy').format(fechaVenc) : '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = IntCellValue(diasRestantes);
      }
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/productos_vencer_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }
}

// ==================== REPORTE DE CAJA ====================

class CashReportPage extends StatefulWidget {
  const CashReportPage({super.key});

  @override
  State<CashReportPage> createState() => _CashReportPageState();
}

class _CashReportPageState extends State<CashReportPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadCashData();
  }

  Future<void> _loadCashData() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final sales = await ApiService.getSales(businessId: provider.currentBusinessId);
      
      // Filtrar ventas por fecha y método de pago
      final filteredSales = sales.where((sale) {
        final saleDate = sale['fecha'] is DateTime
            ? sale['fecha'] as DateTime
            : DateTime.tryParse(sale['fecha']?.toString() ?? '');
        if (saleDate == null) return false;
        return saleDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
               saleDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      double totalCash = 0;
      double totalCard = 0;
      double totalYape = 0;
      double totalPlin = 0;

      for (var sale in filteredSales) {
        final metodo = sale['metodo_pago'] ?? 'efectivo';
        final total = (sale['total'] ?? 0.0) as num;
        
        switch (metodo) {
          case 'efectivo':
            totalCash += total.toDouble();
            break;
          case 'tarjeta':
            totalCard += total.toDouble();
            break;
          case 'yape':
            totalYape += total.toDouble();
            break;
          case 'plin':
            totalPlin += total.toDouble();
            break;
        }
      }

      final total = totalCash + totalCard + totalYape + totalPlin;

      setState(() {
        _stats = {
          'totalCash': totalCash,
          'totalCard': totalCard,
          'totalYape': totalYape,
          'totalPlin': totalPlin,
          'total': total,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos de caja: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilters(),
                  const SizedBox(height: 24),
                  _buildCashStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(true),
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
                  Text(DateFormat('dd/MM/yyyy').format(_startDate)),
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
            onTap: () => _selectDate(false),
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
                  Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
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
      _loadCashData();
    }
  }

  Widget _buildCashStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          children: [
            isMobile
                ? Column(
                    children: [
                      _buildStatCard('Efectivo', 'S/ ${_stats['totalCash']?.toStringAsFixed(2) ?? '0.00'}', Icons.money, Colors.green),
                      const SizedBox(height: 12),
                      _buildStatCard('Tarjeta', 'S/ ${_stats['totalCard']?.toStringAsFixed(2) ?? '0.00'}', Icons.credit_card, Colors.blue),
                      const SizedBox(height: 12),
                      _buildStatCard('Yape', 'S/ ${_stats['totalYape']?.toStringAsFixed(2) ?? '0.00'}', Icons.account_balance_wallet, Colors.orange),
                      const SizedBox(height: 12),
                      _buildStatCard('Plin', 'S/ ${_stats['totalPlin']?.toStringAsFixed(2) ?? '0.00'}', Icons.phone_android, Colors.purple),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildStatCard('Efectivo', 'S/ ${_stats['totalCash']?.toStringAsFixed(2) ?? '0.00'}', Icons.money, Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Tarjeta', 'S/ ${_stats['totalCard']?.toStringAsFixed(2) ?? '0.00'}', Icons.credit_card, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Yape', 'S/ ${_stats['totalYape']?.toStringAsFixed(2) ?? '0.00'}', Icons.account_balance_wallet, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Plin', 'S/ ${_stats['totalPlin']?.toStringAsFixed(2) ?? '0.00'}', Icons.phone_android, Colors.purple)),
                    ],
                  ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL CAJA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'S/ ${_stats['total']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = await PDFService.generateCashReportPDF(
        stats: _stats,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reporte_caja_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Caja'];
      
      // Headers
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Método de Pago');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Monto');
      
      // Data
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue('Efectivo');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = DoubleCellValue(_stats['totalCash'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = TextCellValue('Tarjeta');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = DoubleCellValue(_stats['totalCard'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('Yape');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = DoubleCellValue(_stats['totalYape'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4)).value = TextCellValue('Plin');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value = DoubleCellValue(_stats['totalPlin'] ?? 0.0);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5)).value = TextCellValue('TOTAL');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5)).value = DoubleCellValue(_stats['total'] ?? 0.0);
      
      excel.delete('Sheet1');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/reporte_caja_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }
}
