import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';

class DashboardPageReal extends StatefulWidget {
  const DashboardPageReal({super.key});

  @override
  State<DashboardPageReal> createState() => _DashboardPageRealState();
}

class _DashboardPageRealState extends State<DashboardPageReal> {
  Map<String, dynamic>? _stats;
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final businessId = provider.currentBusinessId;

      if (businessId.isEmpty) {
        throw Exception('No hay negocio seleccionado');
      }

      // Cargar estadísticas y alertas en paralelo
      final results = await Future.wait([
        ApiService.getDashboardStats(businessId),
        ApiService.getCriticalAlerts(businessId),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>?;
        _alerts = results[1] as List<dynamic>;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      
      // Mostrar datos de ejemplo si falla
      setState(() {
        _stats = {
          'sales': {
            'today': {'count': 0, 'amount': 0.0},
            'month': {'count': 0, 'amount': 0.0},
            'growth': 0.0,
          },
          'inventory': {
            'total': 0,
            'inStock': 0,
            'lowStock': 0,
            'outOfStock': 0,
          },
          'clients': {
            'total': 0,
            'withDebt': 0,
          },
          'topProducts': [],
        };
        _alerts = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usando datos de ejemplo: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
          child: _DashboardContentReal(
            stats: _stats,
            alerts: _alerts,
            isLoading: _isLoading,
            error: _error,
            onRefresh: _loadDashboardData,
          ),
        );
      },
    );
  }
}

class _DashboardContentReal extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final List<dynamic> alerts;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const _DashboardContentReal({
    required this.stats,
    required this.alerts,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final businessCategory = provider.currentBusinessCategory;

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth > 600 ? 24.0 : 16.0;
              final spacing = constraints.maxWidth > 600 ? 32.0 : 24.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(businessCategory),
                    SizedBox(height: spacing),

                    // Alertas críticas
                    if (alerts.isNotEmpty) ...[
                      _buildAlertsSection(alerts),
                      SizedBox(height: spacing),
                    ],

                    // Grid de métricas
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1200 ? 4 :
                                              constraints.maxWidth > 800 ? 3 : 2;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: _buildMetricCards(stats),
                        );
                      },
                    ),

                    SizedBox(height: spacing),
                    _buildQuickActions(businessCategory),
                    SizedBox(height: spacing),

                    // Top productos
                    if (stats?['topProducts'] != null && (stats!['topProducts'] as List).isNotEmpty)
                      _buildTopProductsSection(stats!['topProducts']),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(String category) {
    final hour = DateTime.now().hour;
    String greeting = '¡Hola!';
    if (hour < 12) {
      greeting = '¡Buenos días!';
    } else if (hour < 18) {
      greeting = '¡Buenas tardes!';
    } else {
      greeting = '¡Buenas noches!';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final titleSize = isMobile ? 24.0 : 28.0;
        final subtitleSize = isMobile ? 14.0 : 16.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vista general de tu negocio',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.refresh, color: Color(0xFF2563EB), size: 24),
                  ),
                  onPressed: onRefresh,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertsSection(List<dynamic> alertsList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Alertas Importantes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alertsList.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: alert['severity'] == 'critical' ? Colors.red : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alert['message'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<Widget> _buildMetricCards(Map<String, dynamic>? data) {
    if (data == null) {
      return List.filled(4, const SizedBox.shrink());
    }

    final sales = data['sales'] ?? {};
    final inventory = data['inventory'] ?? {};
    final clients = data['clients'] ?? {};

    final monthAmount = sales['month']?['amount']?.toDouble() ?? 0.0;
    final growth = sales['growth']?.toDouble() ?? 0.0;
    final growthText = growth > 0 ? '+${growth.toStringAsFixed(1)}%' : '${growth.toStringAsFixed(1)}%';

    return [
      _buildMetricCard(
        'Ventas del Mes',
        'S/ ${monthAmount.toStringAsFixed(2)}',
        Icons.trending_up,
        const Color(0xFF10B981),
        growthText,
      ),
      _buildMetricCard(
        'Productos',
        '${inventory['total'] ?? 0}',
        Icons.inventory_2,
        const Color(0xFF2563EB),
        '${inventory['inStock'] ?? 0} en stock',
      ),
      _buildMetricCard(
        'Clientes',
        '${clients['total'] ?? 0}',
        Icons.people,
        const Color(0xFF8B5CF6),
        'Registrados',
      ),
      _buildMetricCard(
        'Stock Bajo',
        '${inventory['lowStock'] ?? 0}',
        Icons.warning,
        const Color(0xFFEF4444),
        'Alerta',
      ),
    ];
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String extraInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              extraInfo,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos Rápidos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickActionGrid(category),
      ],
    );
  }

  Widget _buildQuickActionGrid(String category) {
    final actions = _getQuickActionsForCategory(category);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 400) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(action);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getQuickActionsForCategory(String category) {
    final baseActions = [
      {'icon': Icons.receipt, 'label': 'Boletas', 'color': const Color(0xFF2563EB)},
      {'icon': Icons.description, 'label': 'Facturas', 'color': const Color(0xFF10B981)},
      {'icon': Icons.payment, 'label': 'iZipay', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.print, 'label': 'Imprimir', 'color': const Color(0xFF64748B)},
    ];

    switch (category) {
      case 'abarrotes':
        return [
          ...baseActions,
          {'icon': Icons.calendar_today, 'label': 'Vencimientos', 'color': const Color(0xFFEF4444)},
        ];
      default:
        return baseActions;
    }
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Builder(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToQuickAction(context, action),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    action['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
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

  void _navigateToQuickAction(BuildContext context, Map<String, dynamic> action) {
    final label = action['label'] as String;
    switch (label) {
      case 'Boletas':
        context.push('/boletas');
        break;
      case 'Facturas':
        context.push('/facturas');
        break;
      case 'iZipay':
        context.push('/config/zipay');
        break;
      case 'Imprimir':
        context.push('/config/printer');
        break;
      case 'Vencimientos':
        break;
      case 'Proveedores':
        context.push('/providers');
        break;
    }
  }

  Widget _buildTopProductsSection(List<dynamic> topProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos Más Vendidos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: topProducts.take(5).map((product) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                  child: Icon(Icons.inventory_2, color: const Color(0xFF2563EB)),
                ),
                title: Text(product['name'] ?? ''),
                subtitle: Text('Categoría: ${product['category'] ?? ''}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product['unitsSold'] ?? 0} und',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${product['timesSold'] ?? 0} ventas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}


