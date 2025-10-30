import 'package:flutter/material.dart';

class ConfigurationStep extends StatelessWidget {
  final String rubro;
  final Map<String, dynamic> configuraciones;

  const ConfigurationStep({
    super.key,
    required this.rubro,
    required this.configuraciones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Específica'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: _buildConfigurationOptions(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Guardar configuraciones y navegar al siguiente paso
                Navigator.of(context).pushNamed('/next-step');
              },
              child: const Text('Guardar y Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfigurationOptions() {
    switch (rubro) {
      case 'abarrotes':
        return [
          _buildCheckbox('Manejo productos con fecha de vencimiento', 'maneja_vencimientos'),
          _buildCheckbox('Uso lector de códigos de barra', 'lector_codigos'),
          _buildCheckbox('Vendo a crédito (fío)', 'vende_a_credito'),
          _buildCheckbox('Recibo pagos con Yape/Plin', 'recibe_yape_plin'),
        ];
      case 'ropa_calzado':
        return [
          _buildCheckbox('Manejo tallas y colores', 'maneja_tallas_colores'),
          _buildCheckbox('Quiero vender en marketplace online', 'vende_marketplace'),
          _buildCheckbox('Vendo por temporada (colecciones)', 'vende_por_temporada'),
          _buildCheckbox('Recibo pagos con Yape/Plin', 'recibe_yape_plin'),
        ];
      case 'papa_mayorista':
        return [
          _buildCheckbox('Vendo por peso (Kg/Sacos/Toneladas)', 'vende_por_peso'),
          _buildCheckbox('Manejo cuentas por cobrar (crédito)', 'maneja_cuentas_cobrar'),
          _buildCheckbox('Tengo proveedores fijos', 'tiene_proveedores'),
          _buildCheckbox('Recibo pagos con Yape/Plin', 'recibe_yape_plin'),
        ];
      case 'electronica':
        return [
          _buildCheckbox('Registro números de serie/IMEI', 'registro_imei'),
          _buildCheckbox('Control de garantías', 'control_garantias'),
          _buildCheckbox('Servicio técnico', 'servicio_tecnico'),
          _buildCheckbox('Marketplace online', 'vende_marketplace'),
        ];
      case 'verduleria':
        return [
          _buildCheckbox('Venta por peso', 'vende_por_peso'),
          _buildCheckbox('Control de frescura/vencimientos', 'control_frescura'),
          _buildCheckbox('Registro de mermas', 'registro_mermas'),
          _buildCheckbox('Pedidos a proveedores', 'pedidos_proveedores'),
        ];
      default:
        return [const Text('No hay configuraciones específicas para este rubro.')];
    }
  }

  Widget _buildCheckbox(String label, String key) {
    return CheckboxListTile(
      title: Text(label),
      value: configuraciones[key] ?? false,
      onChanged: (value) {
        configuraciones[key] = value;
      },
    );
  }
}
