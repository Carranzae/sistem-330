import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'business_data_step.dart';
import 'business_category_step.dart';
import 'configuration_step.dart';
import 'confirmation_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;
  final Map<String, dynamic> _businessData = {
    'rubro': null,
    'modelo_negocio': null,
    'configuracion': {},
    'modulos_activos': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progreso profesional
            _buildProgressBar(),
            // Contenido con PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  BusinessDataStep(
                    onNext: () => _nextStep(),
                    onDataSaved: (data) {
                      // Convertir a Map<String, dynamic> explícitamente
                      final cleanData = Map<String, dynamic>.from(data);
                      _businessData.addAll(cleanData);
                    },
                  ),
                  BusinessCategoryStep(
                    onCategorySelected: (category) {
                      setState(() {
                        _businessData['rubro'] = category;
                      });
                    },
                    onNext: () => _nextStep(),
                  ),
                  _BusinessModelStep(
                    onModelSelected: (model) {
                      setState(() {
                        _businessData['modelo_negocio'] = model;
                      });
                      _nextStep();
                    },
                  ),
                  ConfigurationStep(
                    rubro: _businessData['rubro'] ?? 'abarrotes',
                    configuraciones: _businessData['configuracion'] == null 
                        ? <String, dynamic>{}
                        : Map<String, dynamic>.from(_businessData['configuracion']),
                    onConfigSaved: (config) {
                      setState(() {
                        _businessData['configuracion'] = config;
                      });
                      _nextStep();
                    },
                  ),
                  _OptionalModulesStep(
                    onModulesSelected: (modules) {
                      setState(() {
                        _businessData['modulos_activos'] = modules;
                      });
                      _nextStep();
                    },
                  ),
                  ConfirmationStep(
                    businessData: _businessData,
                    onComplete: () {
                      context.push('/dashboard');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Barra de progreso profesional
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paso ${_currentStep + 1} de $_totalSteps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

// Paso de Modelo de Negocio - Profesional
class _BusinessModelStep extends StatefulWidget {
  final Function(String) onModelSelected;

  const _BusinessModelStep({required this.onModelSelected});

  @override
  State<_BusinessModelStep> createState() => _BusinessModelStepState();
}

class _BusinessModelStepState extends State<_BusinessModelStep> {
  String? _selectedModel;

  final List<Map<String, dynamic>> _businessModels = [
    {
      'id': 'B2C',
      'name': 'Al por MENOR',
      'description': 'Vendes directo al consumidor final',
      'example': 'Cliente entra a tu tienda y compra',
      'icon': Icons.shopping_cart,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'B2B',
      'name': 'Al por MAYOR',
      'description': 'Vendes a otras empresas/revendedores',
      'example': 'Vendes sacos de papa a bodegas',
      'icon': Icons.business_center,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'HIBRIDO',
      'name': 'HÍBRIDO',
      'description': 'Tienes clientes finales Y mayoristas',
      'example': 'Vendes tanto al detalle como por mayor',
      'icon': Icons.trending_up,
      'color': const Color(0xFFF59E0B),
    },
  ];

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
              // Título
              const Text(
                'Modelo de Negocio',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona cómo operas tu negocio',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),
              // Opciones de modelo
              ..._businessModels.map((model) => _buildModelCard(model)),
              const SizedBox(height: 32),
              // Botón continuar
              if (_selectedModel != null)
                ElevatedButton(
                  onPressed: () {
                    widget.onModelSelected(_selectedModel!);
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final isSelected = _selectedModel == model['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? (model['color'] as Color).withOpacity(0.05)
            : Colors.white,
        border: Border.all(
          color: isSelected
              ? model['color'] as Color
              : const Color(0xFFE5E7EB),
          width: isSelected ? 2.5 : 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (model['color'] as Color).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedModel = model['id'] as String);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (model['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    model['icon'] as IconData,
                    color: model['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['name'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? model['color'] as Color
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model['description'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ejemplo: ${model['example'] as String}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: model['color'] as Color,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Paso de Módulos Opcionales - Profesional
class _OptionalModulesStep extends StatefulWidget {
  final Function(List<String>) onModulesSelected;

  const _OptionalModulesStep({required this.onModulesSelected});

  @override
  State<_OptionalModulesStep> createState() => _OptionalModulesStepState();
}

class _OptionalModulesStepState extends State<_OptionalModulesStep> {
  final List<String> _selectedModules = [];

  final List<Map<String, dynamic>> _modules = [
    {
      'id': 'facturacion',
      'name': 'Facturación Electrónica SUNAT',
      'description': 'Emite boletas y facturas electrónicas',
      'price': 'S/ 29/mes',
      'trial': '14 días gratis',
      'icon': Icons.receipt_long,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'yape_plin',
      'name': 'Integración Yape/Plin',
      'description': 'Recibe pagos digitales automáticamente',
      'price': 'S/ 19/mes',
      'trial': '14 días gratis',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'delivery',
      'name': 'Control de Delivery',
      'description': 'Gestiona entregas a domicilio',
      'price': 'S/ 15/mes',
      'trial': '14 días gratis',
      'icon': Icons.delivery_dining,
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'multi_usuario',
      'name': 'Multi-usuario / Empleados',
      'description': 'Hasta 5 usuarios simultáneos',
      'price': 'S/ 25/mes',
      'trial': 'Incluido',
      'icon': Icons.people,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'marketplace',
      'name': 'Marketplace / Tienda Online',
      'description': 'Vende en línea (solo B2C)',
      'price': 'S/ 39/mes',
      'trial': '14 días gratis',
      'icon': Icons.storefront,
      'color': const Color(0xFFEC4899),
    },
  ];

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
                    'Módulos Opcionales',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mejora tu negocio con funciones adicionales',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de módulos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _modules.length,
                itemBuilder: (context, index) {
                  final module = _modules[index];
                  final isSelected = _selectedModules.contains(module['id']);
                  
                  return _buildModuleCard(module, isSelected);
                },
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
                  widget.onModulesSelected(_selectedModules);
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
                child: Text(
                  _selectedModules.isEmpty
                      ? 'Continuar sin módulos'
                      : 'Continuar (${_selectedModules.length} seleccionados)',
                  style: const TextStyle(
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

  Widget _buildModuleCard(Map<String, dynamic> module, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected
              ? (module['color'] as Color)
              : const Color(0xFFE5E7EB),
          width: isSelected ? 2.5 : 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (module['color'] as Color).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedModules.add(module['id'] as String);
            } else {
              _selectedModules.remove(module['id'] as String);
            }
          });
        },
        title: Text(
          module['name'] as String,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (module['color'] as Color)
                : const Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module['description'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (module['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      module['price'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: module['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '14 días gratis',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (module['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            module['icon'] as IconData,
            color: module['color'] as Color,
            size: 28,
          ),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: module['color'] as Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
