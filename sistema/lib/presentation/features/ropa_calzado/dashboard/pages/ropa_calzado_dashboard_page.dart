import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RopaCalzadoDashboardPage extends StatelessWidget {
  const RopaCalzadoDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ropa, Calzado y Accesorios'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de métricas principales
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                _MetricCard(title: 'Ventas Hoy', value: 'S/ 2,450', color: Color(0xFFEC4899), icon: Icons.trending_up),
                _MetricCard(title: 'Pedidos Online', value: '34', color: Color(0xFF3B82F6), icon: Icons.shopping_bag),
                _MetricCard(title: 'Productos en Stock', value: '1,248', color: Color(0xFF10B981), icon: Icons.inventory_2),
                _MetricCard(title: 'Devoluciones', value: '3', color: Color(0xFFF59E0B), icon: Icons.swap_horiz),
              ],
            ),

            const SizedBox(height: 20),

            // Acciones rápidas
            _Section(title: 'Acciones rápidas', child: _QuickActions()),

            const SizedBox(height: 20),

            // Categorías destacadas
            _Section(
              title: 'Categorías destacadas',
              child: _CategoryChips(
                categories: const ['Vestidos', 'Camisas', 'Pantalones', 'Zapatos', 'Accesorios', 'Promociones'],
              ),
            ),

            const SizedBox(height: 20),

            // Tendencias y productos destacados
            _Section(title: 'Tendencias de la semana', child: _TrendingGrid()),

            const SizedBox(height: 20),

            // Alertas de stock
            _Section(title: 'Alertas de stock', child: _StockAlerts()),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _MetricCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ActionButton(label: 'Nuevo producto', icon: Icons.add_box, onTap: () => _go(context, '/ropa_calzado/inventory')),
        _ActionButton(label: 'Ir al Marketplace', icon: Icons.storefront, onTap: () => _go(context, '/ropa_calzado/marketplace')),
        _ActionButton(label: 'Colecciones', icon: Icons.category, onTap: () => _go(context, '/ropa_calzado/collections')),
        _ActionButton(label: 'Variantes', icon: Icons.style, onTap: () => _go(context, '/ropa_calzado/variants')),
      ],
    );
  }

  void _go(BuildContext context, String path) {
    // Navegación declarativa con GoRouter
    context.go(path);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, color: const Color(0xFFEC4899)), const SizedBox(width: 8), Text(label)],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  const _CategoryChips({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map((c) => Chip(
                label: Text(c),
                backgroundColor: Colors.pink[50],
              ))
          .toList(),
    );
  }
}

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.pink[(i % 9 + 1) * 100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(Icons.checkroom, color: Colors.white, size: 40),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Producto destacado', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockAlerts extends StatelessWidget {
  const _StockAlerts();

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'nombre': 'Polera Negra M', 'stock': 2},
      {'nombre': 'Zapatos Blancos 41', 'stock': 3},
      {'nombre': 'Collar Dorado Único', 'stock': 1},
    ];
    return Column(
      children: alerts
          .map(
            (a) => ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text(a['nombre'] as String),
              trailing: Text('Stock: ${a['stock']}'),
            ),
          )
          .toList(),
    );
  }
}