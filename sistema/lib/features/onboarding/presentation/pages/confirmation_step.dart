import 'package:flutter/material.dart';

class ConfirmationStep extends StatelessWidget {
  final Map<String, dynamic> businessData;

  const ConfirmationStep({super.key, required this.businessData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Negocio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Nombre Comercial: ${businessData['nombre_comercial']}'),
            Text('Rubro: ${businessData['rubro']}'),
            Text('Modelo de Negocio: ${businessData['modelo_negocio']}'),
            const SizedBox(height: 16),
            const Text(
              'Configuraciones Activas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildConfigurations(businessData['configuracion']),
            const SizedBox(height: 16),
            const Text(
              'Módulos Opcionales:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildModules(businessData['modulos_activos']),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navegar al dashboard
                Navigator.of(context).pushNamed('/dashboard');
              },
              child: const Text('Ir al Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfigurations(Map<String, dynamic> configuraciones) {
    return configuraciones.entries
        .where((entry) => entry.value == true)
        .map((entry) => Text('- ${entry.key}'))
        .toList();
  }

  List<Widget> _buildModules(Map<String, dynamic> modulos) {
    return modulos.entries
        .where((entry) => entry.value == true)
        .map((entry) => Text('- ${entry.key}'))
        .toList();
  }
}
