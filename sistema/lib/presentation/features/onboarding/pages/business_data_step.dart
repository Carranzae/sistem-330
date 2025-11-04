import 'package:flutter/material.dart';

class BusinessDataStep extends StatefulWidget {
  final VoidCallback onNext;
  final Function(Map<String, dynamic>) onDataSaved;

  const BusinessDataStep({
    super.key,
    required this.onNext,
    required this.onDataSaved,
  });

  @override
  State<BusinessDataStep> createState() => _BusinessDataStepState();
}

class _BusinessDataStepState extends State<BusinessDataStep> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  final _direccionController = TextEditingController();
  String _selectedPais = 'Perú';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'Datos del Negocio',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa la información básica de tu negocio',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 40),
                // Nombre Comercial
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Comercial *',
                    hintText: 'Ej: Mi Tienda S.A.C.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.store),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre comercial es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // RUC
                TextFormField(
                  controller: _rucController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'RUC (Opcional)',
                    hintText: '11 dígitos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.badge_outlined),
                    suffixIcon: _rucController.text.length == 11
                        ? IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // Aquí se llamaría a la API de SUNAT
                            },
                          )
                        : null,
                  ),
                  maxLength: 11,
                ),
                const SizedBox(height: 20),
                // País
                DropdownButtonFormField<String>(
                  value: _selectedPais,
                  decoration: InputDecoration(
                    labelText: 'País',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.public),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Perú', child: Text('Perú')),
                    DropdownMenuItem(value: 'Chile', child: Text('Chile')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPais = value ?? 'Perú');
                  },
                ),
                const SizedBox(height: 20),
                // Dirección
                TextFormField(
                  controller: _direccionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Dirección Completa *',
                    hintText: 'Ej: Av. Principal 123, Lima',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Botón continuar
                ElevatedButton(
                  onPressed: _handleNext,
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
      ),
    );
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nombre_comercial': _nombreController.text,
        'ruc': _rucController.text.isEmpty ? null : _rucController.text,
        'pais': _selectedPais,
        'direccion_completa': _direccionController.text,
      };
      widget.onDataSaved(data);
      widget.onNext();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}
