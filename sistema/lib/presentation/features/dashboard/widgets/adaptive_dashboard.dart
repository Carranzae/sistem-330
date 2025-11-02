import 'package:flutter/material.dart';

class AdaptiveDashboard extends StatelessWidget {
  final String rubro;
  final String modeloNegocio;
  final Map<String, dynamic> configuracion;
  final Map<String, dynamic> modulosActivos;

  const AdaptiveDashboard({
    super.key,
    required this.rubro,
    required this.modeloNegocio,
    required this.configuracion,
    required this.modulosActivos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        children: [
          _buildHeader(),
          _buildSalesCard(),
          ..._buildConditionalWidgets(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(configuracion['logo_url'] ?? ''),
      ),
      title: Text(configuracion['nombre_comercial'] ?? 'Negocio'),
      subtitle: Text('Rubro: $rubro'),
    );
  }

  Widget _buildSalesCard() {
    return Card(
      child: ListTile(
        title: const Text('Ventas del Día'),
        subtitle: const Text('S/ 0.00'),
        trailing: const Icon(Icons.bar_chart),
      ),
    );
  }

  List<Widget> _buildConditionalWidgets() {
    final widgets = <Widget>[];

    if (rubro == 'abarrotes' && configuracion['maneja_vencimientos'] == true) {
      widgets.add(_buildExpiringProductsWidget());
    }

    if (rubro == 'ropa_calzado' && configuracion['maneja_tallas_colores'] == true) {
      widgets.add(_buildTopSellingProductsWidget());
    }

    if ((rubro == 'papa_mayorista' || modeloNegocio == 'B2B') &&
        configuracion['maneja_cuentas_cobrar'] == true) {
      widgets.add(_buildAccountsReceivableWidget());
    }

    if (configuracion['vende_por_peso'] == true) {
      widgets.add(_buildWeightSoldWidget());
    }

    if (modulosActivos['marketplace'] == true) {
      widgets.add(_buildOnlineOrdersWidget());
    }

    return widgets;
  }

  Widget _buildExpiringProductsWidget() {
    return Card(
      child: ListTile(
        title: const Text('Productos por Vencer'),
        subtitle: const Text('Próximos 7 días'),
        trailing: const Icon(Icons.warning),
      ),
    );
  }

  Widget _buildTopSellingProductsWidget() {
    return Card(
      child: ListTile(
        title: const Text('Productos Más Vendidos'),
        subtitle: const Text('Hoy'),
        trailing: const Icon(Icons.star),
      ),
    );
  }

  Widget _buildAccountsReceivableWidget() {
    return Card(
      child: ListTile(
        title: const Text('Cuentas por Cobrar'),
        subtitle: const Text('Clientes con deuda'),
        trailing: const Icon(Icons.money),
      ),
    );
  }

  Widget _buildWeightSoldWidget() {
    return Card(
      child: ListTile(
        title: const Text('Peso Vendido Hoy'),
        subtitle: const Text('Kg/Toneladas'),
        trailing: const Icon(Icons.scale),
      ),
    );
  }

  Widget _buildOnlineOrdersWidget() {
    return Card(
      child: ListTile(
        title: const Text('Pedidos Online'),
        subtitle: const Text('Marketplace activo'),
        trailing: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
