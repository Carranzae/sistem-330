import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';

/// Formulario completo para agregar/editar productos
class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product; // null para nuevo, data para editar

  const AddProductPage({
    super.key,
    this.product,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockActualController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaVencimientoController = TextEditingController();

  DateTime? _selectedDate;
  
  String _selectedCategory = 'Abarrotes';
  String _selectedUnit = 'UND';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'Abarrotes',
    'Lácteos',
    'Bebidas',
    'Limpieza',
    'Congelados',
    'Carnes',
    'Verduras',
    'Frutas',
    'Otros',
  ];

  final List<String> _units = [
    'UND',
    'KG',
    'LT',
    'GR',
    'ML',
    'SACO',
    'CAJA',
    'PAQ',
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() {
    if (widget.product != null) {
      _nombreController.text = widget.product!['nombre'] ?? '';
      _codigoController.text = widget.product!['codigo'] ?? '';
      _precioCompraController.text = widget.product!['precio_compra']?.toString() ?? '';
      _precioVentaController.text = widget.product!['precio_venta']?.toString() ?? '';
      _stockActualController.text = widget.product!['stock_actual']?.toString() ?? '';
      _stockMinimoController.text = widget.product!['stock_minimo']?.toString() ?? '';
      _descripcionController.text = widget.product!['descripcion'] ?? '';
      _selectedCategory = widget.product!['categoria'] ?? 'Abarrotes';
      _selectedUnit = widget.product!['unidad'] ?? 'UND';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockActualController.dispose();
    _stockMinimoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.hasBusiness) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MainLayout(
          businessCategory: provider.currentBusinessCategory,
          businessName: provider.currentBusinessName,
          child: _buildForm(provider),
        );
      },
    );
  }

  Widget _buildForm(AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.product == null ? 'Agregar Producto' : 'Editar Producto',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Imagen del producto
            _buildImageSection(),
            const SizedBox(height: 32),

            // Información básica
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre del Producto *',
              hint: 'Ej: Arroz Extra Superior',
              icon: Icons.inventory_2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _codigoController,
                    label: 'Código/SKU *',
                    hint: 'Ej: ARR-001',
                    icon: Icons.qr_code,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El código es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: 'Categoría *',
                    value: _selectedCategory,
                    items: _categories,
                    icon: Icons.category,
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              hint: 'Descripción detallada del producto',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Precios
            _buildSectionTitle('Precios'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _precioCompraController,
                    label: 'Precio de Compra *',
                    hint: '0.00',
                    icon: Icons.trending_down,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _precioVentaController,
                    label: 'Precio de Venta *',
                    hint: '0.00',
                    icon: Icons.trending_up,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stock
            _buildSectionTitle('Gestión de Stock'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _stockActualController,
                    label: 'Stock Actual *',
                    hint: '0',
                    icon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El stock es obligatorio';
                      }
                      if (int.tryParse(value) == null || int.parse(value) < 0) {
                        return 'Stock inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _stockMinimoController,
                    label: 'Stock Mínimo *',
                    hint: '0',
                    icon: Icons.warning,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El stock mínimo es obligatorio';
                      }
                      if (int.tryParse(value) == null || int.parse(value) < 0) {
                        return 'Stock inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Unidad de Medida',
              value: _selectedUnit,
              items: _units,
              icon: Icons.scale,
              onChanged: (value) => setState(() => _selectedUnit = value!),
            ),

            // Campo de fecha de vencimiento condicional
            if (provider.manejaVencimientos) ...[
              const SizedBox(height: 16),
              _buildDateField(context),
            ],

            const SizedBox(height: 32),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Guardando...' : (widget.product == null ? 'Guardar Producto' : 'Actualizar Producto'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate, size: 48, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 8),
                        Text(
                          'Agregar Imagen',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedImage != null)
            TextButton.icon(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar Imagen'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final productData = {
        'negocio_id': provider.currentBusinessId,
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'categoria': _selectedCategory,
        'codigo_barras': _codigoController.text.trim(),
        'precio': double.parse(_precioVentaController.text),
        'stock': int.parse(_stockActualController.text),
        'atributos': {
          'precio_compra': double.parse(_precioCompraController.text),
          'stock_minimo': int.parse(_stockMinimoController.text),
          'unidad': _selectedUnit,
          'imagen_url': _selectedImage?.path,
          'fecha_vencimiento': _selectedDate?.toIso8601String(),
        },
      };

      if (widget.product == null) {
        // Crear nuevo producto
        await ApiService.createProduct(productData);
      } else {
        // Actualizar producto existente
        final productId = widget.product!['id'];
        await ApiService.updateProduct(productId, productData);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.product == null 
                        ? 'Producto agregado exitosamente'
                        : 'Producto actualizado exitosamente',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _fechaVencimientoController,
      decoration: InputDecoration(
        labelText: 'Fecha de Vencimiento',
        hintText: 'Selecciona una fecha',
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaVencimientoController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
}

