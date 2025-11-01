import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../data/models/business.dart';

class ConfirmationStep extends StatelessWidget {
  final Map<String, dynamic> businessData;
  final VoidCallback? onComplete;

  const ConfirmationStep({
    super.key,
    required this.businessData,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono de éxito
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Título
              const Text(
                '¡Todo Listo!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu negocio ha sido configurado exitosamente',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Resumen
              _buildSummaryCard(),
              const SizedBox(height: 32),
              // Botón ir al dashboard
              ElevatedButton(
                onPressed: () {
                  _saveBusinessAndNavigate(context);
                  onComplete?.call();
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
                  'Ir al Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem(
            'Nombre Comercial',
            businessData['nombre_comercial']?.toString() ?? 'No especificado',
            Icons.store,
          ),
          const Divider(height: 32),
          _buildSummaryItem(
            'Rubro',
            _getRubroName(businessData['rubro']?.toString() ?? ''),
            Icons.category,
          ),
          const Divider(height: 32),
          _buildSummaryItem(
            'Modelo de Negocio',
            businessData['modelo_negocio']?.toString() ?? 'No especificado',
            Icons.business,
          ),
          if (_hasConfigurations()) ...[
            const Divider(height: 32),
            _buildConfigurationsSection(),
          ],
          if (_hasModules()) ...[
            const Divider(height: 32),
            _buildModulesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationsSection() {
    final configs = businessData['configuracion'] as Map<String, dynamic>?;
    if (configs == null) return const SizedBox.shrink();
    
    final activeConfigs = configs.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
    
    if (activeConfigs.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF2563EB), size: 24),
            SizedBox(width: 16),
            Text(
              'Configuraciones Activas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...activeConfigs.map((config) => Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                config.replaceAll('_', ' ').split(' ').map((word) => 
                  word[0].toUpperCase() + word.substring(1)
                ).join(' '),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildModulesSection() {
    final modules = businessData['modulos_activos'];
    if (modules == null || (modules is List && modules.isEmpty)) {
      return const SizedBox.shrink();
    }
    
    List<String> moduleList = [];
    if (modules is List) {
      moduleList = modules.cast<String>();
    } else if (modules is Map) {
      moduleList = modules.keys.toList().cast<String>();
    }
    
    if (moduleList.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.extension, color: Color(0xFF2563EB), size: 24),
            SizedBox(width: 16),
            Text(
              'Módulos Activos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...moduleList.map((module) => Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                module.replaceAll('_', ' ').split(' ').map((word) => 
                  word[0].toUpperCase() + word.substring(1)
                ).join(' '),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  bool _hasConfigurations() {
    final configs = businessData['configuracion'] as Map<String, dynamic>?;
    if (configs == null) return false;
    return configs.entries.any((entry) => entry.value == true);
  }

  bool _hasModules() {
    final modules = businessData['modulos_activos'];
    if (modules == null) return false;
    if (modules is List) return modules.isNotEmpty;
    if (modules is Map) return modules.isNotEmpty;
    return false;
  }

  String _getRubroName(String rubro) {
    final rubros = {
      'abarrotes': 'Abarrotes / Bodega',
      'ropa_calzado': 'Ropa, Calzado y Accesorios',
      'hogar_decoracion': 'Hogar y Decoración',
      'electronica': 'Electrónica y Tecnología',
      'verduleria': 'Verdulería / Frutas',
      'papa_mayorista': 'Venta de Papa / Tubérculos',
      'carniceria': 'Carnicería / Pollería',
      'ferreteria': 'Ferretería / Construcción',
      'farmacia': 'Farmacia / Botica',
      'restaurante': 'Restaurante / Comida',
      'mayorista': 'Mayorista / Distribuidor',
      'otro': 'Otro / General',
    };
    return rubros[rubro] ?? rubro;
  }

  void _saveBusinessAndNavigate(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Convertir configuracion y modulosActivos a Map<String, dynamic>
    Map<String, dynamic> configuracion = {};
    if (businessData['configuracion'] != null) {
      configuracion = Map<String, dynamic>.from(businessData['configuracion']);
    }
    
    Map<String, dynamic> modulosActivos = {};
    if (businessData['modulos_activos'] != null) {
      if (businessData['modulos_activos'] is List) {
        // Si es una lista, convertir a un mapa con los valores activos
        final lista = businessData['modulos_activos'] as List;
        for (var modulo in lista) {
          modulosActivos[modulo.toString()] = true;
        }
      } else {
        modulosActivos = Map<String, dynamic>.from(businessData['modulos_activos']);
      }
    }
    
    // Crear objeto Business desde businessData
    final business = Business(
      id: '', // Se asignará después de guardar en backend
      userId: '', // Se asignará después del registro
      nombreComercial: businessData['nombre_comercial']?.toString() ?? 'Mi Negocio',
      ruc: businessData['ruc']?.toString(),
      logoUrl: businessData['logo_url']?.toString(),
      pais: businessData['pais']?.toString() ?? 'Perú',
      departamento: businessData['departamento']?.toString() ?? '',
      provincia: businessData['provincia']?.toString() ?? '',
      distrito: businessData['distrito']?.toString() ?? '',
      direccionCompleta: businessData['direccion_completa']?.toString() ?? '',
      moneda: businessData['moneda']?.toString() ?? 'PEN',
      rubro: businessData['rubro']?.toString() ?? 'otro',
      modeloNegocio: businessData['modelo_negocio']?.toString() ?? 'B2C',
      configuracion: configuracion,
      modulosActivos: modulosActivos,
    );
    
    // Guardar en el provider
    provider.setCurrentBusiness(business);
    
    // TODO: Aquí se debería guardar el negocio en el backend/Supabase
    // Por ahora solo lo guardamos en memoria para la demo
  }
}
