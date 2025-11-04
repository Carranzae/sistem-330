import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

/// Módulo de Reportes - Gestión de reportes para Abarrotes y Bodega
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _getReports(category).length,
            itemBuilder: (context, index) {
              return _buildReportCard(_getReports(category)[index]);
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
        'onTap': () => _showReportPreview('Ventas'),
      },
      {
        'title': 'Reporte de Inventario',
        'description': 'Stock, valoración y rotación',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF2563EB),
        'onTap': () => _showReportPreview('Inventario'),
      },
      {
        'title': 'Reporte Financiero',
        'description': 'Ganancias, pérdidas y márgenes',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => _showReportPreview('Financiero'),
      },
      {
        'title': 'Reporte de Clientes',
        'description': 'Análisis de clientes y créditos',
        'icon': Icons.people,
        'color': const Color(0xFFEC4899),
        'onTap': () => _showReportPreview('Clientes'),
      },
      if (category == 'abarrotes')
        {
          'title': 'Productos por Vencer',
          'description': 'Alertas de vencimientos',
          'icon': Icons.warning,
          'color': const Color(0xFFEF4444),
          'onTap': () => _showReportPreview('Vencimientos'),
        },
      {
        'title': 'Reporte de Caja',
        'description': 'Arqueo y balance de caja',
        'icon': Icons.receipt,
        'color': const Color(0xFFF59E0B),
        'onTap': () => _showReportPreview('Caja'),
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

  void _showReportPreview(String reportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reporte de $reportType'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assessment,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Este reporte estará disponible en la próxima actualización',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Características futuras:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Filtros por fecha y categoría'),
                    _buildFeatureItem('Gráficos interactivos'),
                    _buildFeatureItem('Exportación a PDF y Excel'),
                    _buildFeatureItem('Comparativas y tendencias'),
                  ],
                ),
              ),
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport(String reportTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Descargando $reportTitle...'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
