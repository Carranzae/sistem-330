import 'package:flutter/material.dart';

class ConfigurationStep extends StatefulWidget {
  final String rubro;
  final Map<String, dynamic> configuraciones;
  final Function(Map<String, dynamic>)? onConfigSaved;

  const ConfigurationStep({
    super.key,
    required this.rubro,
    required this.configuraciones,
    this.onConfigSaved,
  });

  @override
  State<ConfigurationStep> createState() => _ConfigurationStepState();
}

class _ConfigurationStepState extends State<ConfigurationStep> {
  late Map<String, dynamic> _configuraciones;

  @override
  void initState() {
    super.initState();
    // Conversión segura para evitar errores de tipo LinkedMap
    try {
      _configuraciones = Map<String, dynamic>.from(widget.configuraciones);
    } catch (e) {
      // Si falla la conversión, usar un mapa vacío
      _configuraciones = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración Específica',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Personaliza tu sistema según tus necesidades',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: _buildConfigurationOptions(),
              ),
            ),
            // Botón continuar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfigSaved?.call(_configuraciones);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfigurationOptions() {
    switch (widget.rubro) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        value: _configuraciones[key] ?? false,
        onChanged: (value) {
          setState(() {
            _configuraciones[key] = value ?? false;
          });
        },
        activeColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
