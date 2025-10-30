import 'package:flutter/material.dart';

class BusinessDataStep extends StatefulWidget {
  const BusinessDataStep({super.key});

  @override
  State<BusinessDataStep> createState() => _BusinessDataStepState();
}

class _BusinessDataStepState extends State<BusinessDataStep> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _businessData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del Negocio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre Comercial'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre comercial es requerido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _businessData['nombre_comercial'] = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'RUC (opcional)'),
                onSaved: (value) {
                  _businessData['ruc'] = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'País'),
                value: 'Perú',
                items: const [
                  DropdownMenuItem(value: 'Perú', child: Text('Perú')),
                  DropdownMenuItem(value: 'Chile', child: Text('Chile')),
                ],
                onChanged: (value) {
                  _businessData['pais'] = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección Exacta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La dirección es requerida';
                  }
                  return null;
                },
                onSaved: (value) {
                  _businessData['direccion_completa'] = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.of(context).pushNamed(
                      '/next-step',
                      arguments: _businessData,
                    );
                  }
                },
                child: const Text('Guardar y Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
