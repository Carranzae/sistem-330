import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.hasBusiness) {
          // Si no hay negocio registrado, redirigir al onboarding
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return MainLayout(
          businessCategory: provider.currentBusinessCategory,
          businessName: provider.currentBusinessName,
          child: _DashboardContent(),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.hasBusiness) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final businessCategory = provider.currentBusinessCategory;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del módulo con saludo
              _buildHeader(businessCategory),
              const SizedBox(height: 32),
              
              // Grid de métricas responsive
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
                    children: [
                      _buildMetricCard(
                        'Ventas del Mes',
                        'S/ 0.00',
                        Icons.trending_up,
                        const Color(0xFF10B981),
                        '+12.5%',
                      ),
                      _buildMetricCard(
                        'Productos',
                        '0',
                        Icons.inventory_2,
                        const Color(0xFF2563EB),
                        'Activos',
                      ),
                      _buildMetricCard(
                        'Clientes',
                        '0',
                        Icons.people,
                        const Color(0xFF8B5CF6),
                        'Registrados',
                      ),
                      _buildMetricCard(
                        'Stock Bajo',
                        '0',
                        Icons.warning,
                        const Color(0xFFEF4444),
                        'Alerta',
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Accesos rápidos según rubro
              _buildQuickActions(businessCategory),
              const SizedBox(height: 32),
              
              // Gráficos y tablas responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildChartCard(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRecentActivityCard(),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildChartCard(),
                        const SizedBox(height: 16),
                        _buildRecentActivityCard(),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(String category) {
    // Saludos según hora del día
    final hour = DateTime.now().hour;
    String greeting = '¡Hola!';
    if (hour < 12) {
      greeting = '¡Buenos días!';
    } else if (hour < 18) {
      greeting = '¡Buenas tardes!';
    } else {
      greeting = '¡Buenas noches!';
    }
    
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vista general de tu negocio',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Botón de impresora
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.print,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              onPressed: () {
                // TODO: Abrir menú de impresión
              },
            ),
          ],
        ),
      ],
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
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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
  }
  
  List<Map<String, dynamic>> _getQuickActionsForCategory(String category) {
    final baseActions = [
      {'icon': Icons.receipt, 'label': 'Boletas', 'color': const Color(0xFF2563EB)},
      {'icon': Icons.description, 'label': 'Facturas', 'color': const Color(0xFF10B981)},
      {'icon': Icons.payment, 'label': 'iZipay', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.print, 'label': 'Imprimir', 'color': const Color(0xFF64748B)},
    ];
    
    // Agregar acciones específicas según categoría
    switch (category) {
      case 'abarrotes':
        return [
          ...baseActions,
          {'icon': Icons.calendar_today, 'label': 'Vencimientos', 'color': const Color(0xFFEF4444)},
        ];
      case 'papa_mayorista':
      case 'verduleria':
        return [
          ...baseActions,
          {'icon': Icons.local_shipping, 'label': 'Proveedores', 'color': const Color(0xFF8B5CF6)},
          {'icon': Icons.eco, 'label': 'Cosechas', 'color': const Color(0xFF059669)},
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
            onTap: () {
              _navigateToQuickAction(context, action);
            },
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
        // TODO: Navegar a reporte de vencimientos
        break;
      case 'Proveedores':
        context.push('/providers');
        break;
      case 'Cosechas':
        // TODO: Navegar a módulo de cosechas
        break;
    }
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, [String? extraInfo]) {
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
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (extraInfo != null)
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

  Widget _buildChartCard() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ventas por Día',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Icon(
                Icons.bar_chart,
                size: 64,
                color: Color(0xFFE5E7EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Icon(
                Icons.receipt_long,
                size: 64,
                color: Color(0xFFE5E7EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


