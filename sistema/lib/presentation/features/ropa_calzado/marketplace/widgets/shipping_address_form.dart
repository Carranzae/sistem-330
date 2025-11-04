import 'package:flutter/material.dart';

class ShippingAddressForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddressChanged;

  const ShippingAddressForm({
    Key? key,
    required this.onAddressChanged,
  }) : super(key: key);

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _referenceController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String selectedDeliveryOption = 'standard';

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _nameController.addListener(_updateAddress);
    _phoneController.addListener(_updateAddress);
    _addressController.addListener(_updateAddress);
    _referenceController.addListener(_updateAddress);
    _districtController.addListener(_updateAddress);
    _cityController.addListener(_updateAddress);
    _postalCodeController.addListener(_updateAddress);
  }

  void _updateAddress() {
    widget.onAddressChanged({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'reference': _referenceController.text,
      'district': _districtController.text,
      'city': _cityController.text,
      'postalCode': _postalCodeController.text,
      'deliveryOption': selectedDeliveryOption,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de Envío',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nombre completo
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre Completo *',
              hintText: 'Ingresa tu nombre completo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre completo';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Teléfono
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Teléfono *',
              hintText: '+51 999 999 999',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu teléfono';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Dirección
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Dirección *',
              hintText: 'Av. Principal 123, Urbanización...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu dirección';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Referencia
          TextFormField(
            controller: _referenceController,
            decoration: InputDecoration(
              labelText: 'Referencia',
              hintText: 'Frente al parque, casa azul...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.info_outline),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Distrito y Ciudad
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText: 'Distrito *',
                    hintText: 'Miraflores',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ciudad *',
                    hintText: 'Lima',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Código postal
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Código Postal',
                hintText: '15074',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.markunread_mailbox),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Opciones de entrega
          const Text(
            'Opciones de Entrega',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDeliveryOption(
            'standard',
            'Entrega Estándar',
            '3-5 días hábiles',
            'S/ 15.00',
            Icons.local_shipping,
          ),
          
          _buildDeliveryOption(
            'express',
            'Entrega Express',
            '1-2 días hábiles',
            'S/ 25.00',
            Icons.flash_on,
          ),
          
          _buildDeliveryOption(
            'pickup',
            'Recojo en Tienda',
            'Disponible hoy',
            'Gratis',
            Icons.store,
          ),
          
          const SizedBox(height: 24),
          
          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de Entrega',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Te enviaremos un SMS con el código de seguimiento una vez que tu pedido sea despachado.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(
    String value,
    String title,
    String time,
    String price,
    IconData icon,
  ) {
    final isSelected = selectedDeliveryOption == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryOption = value;
        });
        _updateAddress();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEC4899).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEC4899) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? const Color(0xFFEC4899) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? const Color(0xFFEC4899) : Colors.black,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFEC4899) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFEC4899) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}