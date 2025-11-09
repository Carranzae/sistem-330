import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';

/// Sistema Empresarial de Pronósticos de Venta y Plan de Compra
class PronosticsPage extends StatefulWidget {
  const PronosticsPage({super.key});

  @override
  State<PronosticsPage> createState() => _PronosticsPageState();
}

class _PronosticsPageState extends State<PronosticsPage> {
  String _selectedFilter = 'continuo'; // temporal o continuo
  String _selectedPeriod = 'mensual'; // semanal, quincenal, mensual, personalizado
  DateTime? _startDate;
  DateTime? _endDate;
  final List<Map<String, dynamic>> _forecasts = [];
  final List<Map<String, dynamic>> _purchasePlan = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadForecasts();
  }

  Future<void> _loadForecasts() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Obtener ventas históricas
      final sales = await ApiService.getSales(businessId: provider.currentBusinessId);
      
      // Obtener productos
      final products = await ApiService.getProducts(businessId: provider.currentBusinessId);
      
      // Calcular pronósticos
      final forecasts = _calculateForecasts(sales, products);
      final purchasePlan = _calculatePurchasePlan(forecasts, products);
      
      setState(() {
        _forecasts.clear();
        _forecasts.addAll(forecasts);
        _purchasePlan.clear();
        _purchasePlan.addAll(purchasePlan);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Si falla, usar datos de muestra
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    setState(() {
      _forecasts.addAll([
        {
          'productId': '1',
          'productName': 'Leche Evaporada',
          'currentStock': 50,
          'forecastWeekly': 35,
          'forecastBiweekly': 70,
          'forecastMonthly': 150,
          'trend': 'Alto',
          'confidence': 0.85,
        },
        {
          'productId': '2',
          'productName': 'Pan Integral',
          'currentStock': 80,
          'forecastWeekly': 70,
          'forecastBiweekly': 140,
          'forecastMonthly': 280,
          'trend': 'Alto',
          'confidence': 0.90,
        },
        {
          'productId': '3',
          'productName': 'Arroz Extra',
          'currentStock': 30,
          'forecastWeekly': 30,
          'forecastBiweekly': 60,
          'forecastMonthly': 120,
          'trend': 'Alto',
          'confidence': 0.88,
        },
        {
          'productId': '4',
          'productName': 'Aceite Vegetal',
          'currentStock': 45,
          'forecastWeekly': 25,
          'forecastBiweekly': 50,
          'forecastMonthly': 100,
          'trend': 'Medio',
          'confidence': 0.75,
        },
      ]);
      
      _purchasePlan.addAll([
        {
          'productId': '1',
          'productName': 'Leche Evaporada',
          'currentStock': 50,
          'recommendedQuantity': 200,
          'reason': 'Stock bajo según pronóstico mensual',
        },
        {
          'productId': '3',
          'productName': 'Arroz Extra',
          'currentStock': 30,
          'recommendedQuantity': 150,
          'reason': 'Stock crítico, alta demanda pronosticada',
        },
        {
          'productId': '4',
          'productName': 'Aceite Vegetal',
          'currentStock': 45,
          'recommendedQuantity': 100,
          'reason': 'Reposición recomendada',
        },
      ]);
    });
  }

  List<Map<String, dynamic>> _calculateForecasts(
    List<dynamic> sales,
    List<dynamic> products,
  ) {
    final forecasts = <Map<String, dynamic>>[];
    
    // Agrupar ventas por producto
    final salesByProduct = <String, List<Map<String, dynamic>>>{};
    
    for (final sale in sales) {
      final items = sale['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final productId = item['product_id'] ?? item['productId'] ?? '';
        if (productId.toString().isNotEmpty) {
          salesByProduct.putIfAbsent(productId.toString(), () => []);
          salesByProduct[productId.toString()]!.add({
            'date': DateTime.tryParse(sale['fecha'] ?? sale['date'] ?? '') ?? DateTime.now(),
            'quantity': (item['cantidad'] ?? item['quantity'] ?? 0) as num,
          });
        }
      }
    }
    
    // Calcular pronósticos para cada producto
    for (final product in products) {
      final productId = product['id'] ?? product['_id'] ?? '';
      final productName = product['nombre'] ?? product['name'] ?? 'Producto';
      final currentStock = (product['stock'] ?? product['stock_actual'] ?? 0) as num;
      
      final productSales = salesByProduct[productId.toString()] ?? [];
      
      if (productSales.isEmpty) {
        // Si no hay ventas, usar valores por defecto
        forecasts.add({
          'productId': productId.toString(),
          'productName': productName,
          'currentStock': currentStock.toDouble(),
          'forecastWeekly': 0.0,
          'forecastBiweekly': 0.0,
          'forecastMonthly': 0.0,
          'trend': 'Bajo',
          'confidence': 0.5,
        });
        continue;
      }
      
      // Calcular promedio móvil de 4 semanas
      final weeklyAvg = _calculateMovingAverage(productSales, 7);
      final biweeklyAvg = weeklyAvg * 2;
      final monthlyAvg = weeklyAvg * 4;
      
      // Calcular tendencia
      final trend = _calculateTrend(productSales);
      final confidence = _calculateConfidence(productSales);
      
      forecasts.add({
        'productId': productId.toString(),
        'productName': productName,
        'currentStock': currentStock.toDouble(),
        'forecastWeekly': weeklyAvg,
        'forecastBiweekly': biweeklyAvg,
        'forecastMonthly': monthlyAvg,
        'trend': trend,
        'confidence': confidence,
      });
    }
    
    // Ordenar por pronóstico mensual descendente
    forecasts.sort((a, b) => (b['forecastMonthly'] as num).compareTo(a['forecastMonthly'] as num));
    
    return forecasts;
  }

  double _calculateMovingAverage(List<Map<String, dynamic>> sales, int days) {
    if (sales.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    final recentSales = sales.where((s) {
      final saleDate = s['date'] as DateTime;
      return saleDate.isAfter(cutoffDate);
    }).toList();
    
    if (recentSales.isEmpty) return 0.0;
    
    final totalQuantity = recentSales.fold<double>(
      0.0,
      (sum, sale) => sum + (sale['quantity'] as num).toDouble(),
    );
    
    return totalQuantity / days;
  }

  String _calculateTrend(List<Map<String, dynamic>> sales) {
    if (sales.length < 2) return 'Medio';
    
    // Comparar últimas 2 semanas vs anteriores 2 semanas
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final recentSales = sales.where((s) {
      final saleDate = s['date'] as DateTime;
      return saleDate.isAfter(twoWeeksAgo);
    }).fold<double>(0.0, (sum, s) => sum + (s['quantity'] as num).toDouble());
    
    final olderSales = sales.where((s) {
      final saleDate = s['date'] as DateTime;
      return saleDate.isAfter(fourWeeksAgo) && saleDate.isBefore(twoWeeksAgo);
    }).fold<double>(0.0, (sum, s) => sum + (s['quantity'] as num).toDouble());
    
    if (recentSales > olderSales * 1.2) return 'Alto';
    if (recentSales < olderSales * 0.8) return 'Bajo';
    return 'Medio';
  }

  double _calculateConfidence(List<Map<String, dynamic>> sales) {
    if (sales.length < 7) return 0.5;
    if (sales.length < 14) return 0.7;
    if (sales.length < 30) return 0.85;
    return 0.95;
  }

  List<Map<String, dynamic>> _calculatePurchasePlan(
    List<Map<String, dynamic>> forecasts,
    List<dynamic> products,
  ) {
    final plan = <Map<String, dynamic>>[];
    
    for (final forecast in forecasts) {
      final productId = forecast['productId'] as String;
      final currentStock = forecast['currentStock'] as double;
      final forecastMonthly = forecast['forecastMonthly'] as double;
      
      // Calcular stock necesario para 1.5 meses (buffer de seguridad)
      final neededStock = forecastMonthly * 1.5;
      final recommendedQuantity = (neededStock - currentStock).ceil();
      
      if (recommendedQuantity > 0) {
        plan.add({
          'productId': productId,
          'productName': forecast['productName'],
          'currentStock': currentStock,
          'recommendedQuantity': recommendedQuantity,
          'forecastMonthly': forecastMonthly,
          'reason': currentStock < forecastMonthly * 0.5
              ? 'Stock crítico, alta demanda pronosticada'
              : currentStock < forecastMonthly
                  ? 'Stock bajo según pronóstico mensual'
                  : 'Reposición recomendada',
        });
      }
    }
    
    // Ordenar por urgencia (stock más bajo primero)
    plan.sort((a, b) {
      final ratioA = (a['currentStock'] as double) / (a['forecastMonthly'] as double);
      final ratioB = (b['currentStock'] as double) / (b['forecastMonthly'] as double);
      return ratioA.compareTo(ratioB);
    });
    
    return plan;
  }

  double _getForecastForPeriod(Map<String, dynamic> forecast) {
    switch (_selectedPeriod) {
      case 'semanal':
        return forecast['forecastWeekly'] as double;
      case 'quincenal':
        return forecast['forecastBiweekly'] as double;
      case 'mensual':
        return forecast['forecastMonthly'] as double;
      default:
        return forecast['forecastMonthly'] as double;
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
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
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
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF14B8A6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pronósticos de Venta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Análisis inteligente de productos y temporadas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Botón exportar Excel
              IconButton(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.download),
                tooltip: 'Exportar a Excel',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6).withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Filtro principal
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip('Temporadas', 'temporal', Icons.calendar_today),
                _buildFilterChip('Continuo', 'continuo', Icons.refresh),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selector de período
          if (_selectedFilter == 'continuo')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 18, color: Color(0xFF14B8A6)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                      DropdownMenuItem(value: 'quincenal', child: Text('Quincenal')),
                      DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                      DropdownMenuItem(value: 'personalizado', child: Text('Personalizado')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value ?? 'mensual';
                        if (value == 'personalizado') {
                          _showDateRangePicker();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Contenido según filtro
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedFilter == 'temporal'
                    ? _buildTemporalView()
                    : _buildContinuousView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedFilter = value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: isSelected ? const Color(0xFF14B8A6) : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF14B8A6) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemporalView() {
    final currentMonth = DateTime.now().month;
    final seasonalProducts = _getSeasonalProducts(currentMonth);

    return ListView(
      children: [
        // Productos estacionales
        Container(
          padding: const EdgeInsets.all(20),
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
              const Text(
                'Productos Estacionales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ...seasonalProducts.map((product) => _buildSeasonalProductCard(
                product['period'],
                product['product'],
                product['note'],
                product['quantity'],
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Plan de compra estacional
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
              const Text(
                'Plan de Compra Estacional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ..._purchasePlan.take(3).map((item) => _buildPurchasePlanCard(
                item['productName'],
                '${item['recommendedQuantity']} unidades',
                'Stock actual: ${(item['currentStock'] as num).toInt()}',
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinuousView() {
    return ListView(
      children: [
        // Productos con pronósticos
        Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pronósticos ${_getPeriodLabel()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '${_forecasts.length} productos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._forecasts.map((forecast) => _buildForecastCard(forecast)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Plan de compra
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Plan de Compra Siguiente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (_purchasePlan.isNotEmpty)
                    Text(
                      '${_purchasePlan.length} productos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_purchasePlan.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay productos que requieran compra',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El stock actual es suficiente según los pronósticos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._purchasePlan.map((item) => _buildPurchasePlanCard(
                  item['productName'],
                  '${item['recommendedQuantity']} unidades',
                  'Stock actual: ${(item['currentStock'] as num).toInt()}',
                )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(Map<String, dynamic> forecast) {
    final forecastValue = _getForecastForPeriod(forecast);
    final trend = forecast['trend'] as String;
    final confidence = forecast['confidence'] as double;
    final trendColor = trend == 'Alto' ? Colors.green : trend == 'Medio' ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Color(0xFF14B8A6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forecast['productName'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${forecastValue.toStringAsFixed(0)} unidades/${_getPeriodLabel().toLowerCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.analytics, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Confianza: ${(confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, size: 16, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalProductCard(String period, String product, String note, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today, color: Color(0xFF14B8A6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$quantity uds',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal.shade700,
                ),
              ),
              Text(
                'necesarias',
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

  Widget _buildPurchasePlanCard(String product, String quantity, String currentStock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_cart, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  currentStock,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              quantity,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSeasonalProducts(int month) {
    if (month >= 1 && month <= 3) {
      return [
        {'period': 'Enero - Marzo', 'product': 'Aceite Vegetal', 'note': 'Alta demanda en inicio de año', 'quantity': 250},
        {'period': 'Enero - Marzo', 'product': 'Azúcar', 'note': 'Pico por fiestas', 'quantity': 180},
      ];
    } else if (month >= 4 && month <= 6) {
      return [
        {'period': 'Abril - Junio', 'product': 'Azúcar', 'note': 'Pico por fiestas', 'quantity': 180},
        {'period': 'Abril - Junio', 'product': 'Harina', 'note': 'Temporada de panadería', 'quantity': 200},
      ];
    } else if (month >= 7 && month <= 9) {
      return [
        {'period': 'Julio - Septiembre', 'product': 'Arroz', 'note': 'Temporada de recolección', 'quantity': 220},
        {'period': 'Julio - Septiembre', 'product': 'Fideos', 'note': 'Alta demanda', 'quantity': 150},
      ];
    } else {
      return [
        {'period': 'Octubre - Diciembre', 'product': 'Harina', 'note': 'Navidad y año nuevo', 'quantity': 300},
        {'period': 'Octubre - Diciembre', 'product': 'Azúcar', 'note': 'Temporada alta', 'quantity': 250},
      ];
    }
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'semanal':
        return 'Semanal';
      case 'quincenal':
        return 'Quincenal';
      case 'mensual':
        return 'Mensual';
      default:
        return 'Mensual';
    }
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadForecasts();
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Pronósticos y Plan de Compra'];

      // Encabezados
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Producto');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Stock Actual');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Pronóstico Semanal');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Pronóstico Quincenal');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue('Pronóstico Mensual');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = TextCellValue('Tendencia');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = TextCellValue('Confianza (%)');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value = TextCellValue('Cantidad Recomendada');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value = TextCellValue('Razón');

      // Datos de pronósticos
      int row = 1;
      for (final forecast in _forecasts) {
        final purchaseItem = _purchasePlan.firstWhere(
          (item) => item['productId'] == forecast['productId'],
          orElse: () => <String, dynamic>{},
        );

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(forecast['productName'] as String? ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = IntCellValue((forecast['currentStock'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue((forecast['forecastWeekly'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = DoubleCellValue((forecast['forecastBiweekly'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = DoubleCellValue((forecast['forecastMonthly'] ?? 0.0) as double);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(forecast['trend'] as String? ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = DoubleCellValue((forecast['confidence'] as double) * 100);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = IntCellValue((purchaseItem['recommendedQuantity'] ?? 0) as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue((purchaseItem['reason'] ?? 'N/A') as String);
        row++;
      }

      // Guardar archivo
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Pronosticos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Abrir archivo
        await OpenFile.open(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Archivo exportado: $fileName'),
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
}

