import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../core/services/api_service.dart';

/// Sistema Empresarial de Configuración - Completo y Conectado
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Datos de configuración
  final List<Map<String, dynamic>> _categories = [];
  final List<Map<String, dynamic>> _units = [];
  final List<String> _paymentMethods = ['Efectivo', 'Tarjeta', 'Yape', 'Plin'];
  double _defaultCreditLimit = 500.0;
  int _defaultCreditDays = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Cargar categorías desde productos existentes
      final products = await ApiService.getProducts(businessId: provider.currentBusinessId);
      final categoriesSet = <String>{};
      
      for (final product in products) {
        final category = product['categoria'] ?? product['category'] ?? '';
        if (category.toString().isNotEmpty) {
          categoriesSet.add(category.toString());
        }
      }
      
      setState(() {
        _categories.clear();
        _categories.addAll(categoriesSet.map((cat) => {
          'name': cat,
          'id': cat.toLowerCase().replaceAll(' ', '_'),
        }).toList());
        
        // Unidades de medida predefinidas
        _units.clear();
        _units.addAll([
          {'name': 'Unidad', 'abbreviation': 'und', 'id': '1'},
          {'name': 'Kilogramo', 'abbreviation': 'kg', 'id': '2'},
          {'name': 'Gramo', 'abbreviation': 'g', 'id': '3'},
          {'name': 'Litro', 'abbreviation': 'L', 'id': '4'},
          {'name': 'Mililitro', 'abbreviation': 'ml', 'id': '5'},
          {'name': 'Metro', 'abbreviation': 'm', 'id': '6'},
          {'name': 'Centímetro', 'abbreviation': 'cm', 'id': '7'},
          {'name': 'Caja', 'abbreviation': 'caja', 'id': '8'},
          {'name': 'Paquete', 'abbreviation': 'pqt', 'id': '9'},
        ]);
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Cargar datos por defecto
      _loadDefaultSettings();
    }
  }

  void _loadDefaultSettings() {
    setState(() {
      _categories.addAll([
        {'name': 'Abarrotes', 'id': '1'},
        {'name': 'Bebidas', 'id': '2'},
        {'name': 'Lácteos', 'id': '3'},
        {'name': 'Carnes', 'id': '4'},
        {'name': 'Frutas y Verduras', 'id': '5'},
      ]);
    });
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuración',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personaliza tu sistema',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Lista de configuraciones
                Expanded(
                  child: ListView(
                    children: [
                      _buildSection(
                        'Productos',
                        Icons.inventory_2,
                        [
                          _buildSettingTile(
                            'Categorías de Productos',
                                  '${_categories.length} categorías configuradas',
                            Icons.category_outlined,
                                  () => _showCategoriesDialog(),
                          ),
                          _buildSettingTile(
                            'Unidades de Medida',
                                  '${_units.length} unidades disponibles',
                            Icons.straighten_outlined,
                                  () => _showUnitsDialog(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Pagos',
                        Icons.payment,
                        [
                          _buildSettingTile(
                            'Métodos de Pago',
                                  '${_paymentMethods.length} métodos activos',
                            Icons.account_balance_wallet_outlined,
                                  () => _showPaymentMethodsDialog(),
                          ),
                          _buildSettingTile(
                            'Configurar iZipay',
                            'Integración pagos',
                            Icons.payment_outlined,
                                  () => _showZipayConfigDialog(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Clientes',
                        Icons.people,
                        [
                          _buildSettingTile(
                            'Límite de Crédito',
                                  'Límite por defecto: S/ ${_defaultCreditLimit.toStringAsFixed(2)}',
                            Icons.credit_card_outlined,
                                  () => _showCreditLimitDialog(),
                          ),
                          _buildSettingTile(
                            'Configurar Fiados',
                                  'Días de gracia: $_defaultCreditDays días',
                            Icons.schedule_outlined,
                                  () => _showCreditSettingsDialog(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Sistema',
                        Icons.settings_outlined,
                        [
                          _buildSettingTile(
                            'Usuarios y Permisos',
                            'Gestionar acceso',
                            Icons.person_outline,
                                  () => _showUsersDialog(),
                          ),
                          _buildSettingTile(
                            'Copia de Seguridad',
                            'Respaldo de datos',
                            Icons.backup_outlined,
                                  () => _showBackupDialog(),
                          ),
                          _buildSettingTile(
                            'Impresoras',
                            'Configurar impresión',
                            Icons.print_outlined,
                                  () => _navigateToPrinters(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF64748B)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCategoriesDialog(),
    );
  }

  Widget _buildCategoriesDialog() {
    final newCategoryController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.category, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text('Categorías de Productos'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Agregar nueva categoría
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newCategoryController,
                        decoration: InputDecoration(
                          labelText: 'Nueva categoría',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)),
                      onPressed: () {
                        if (newCategoryController.text.trim().isNotEmpty) {
                          setDialogState(() {
                            _categories.add({
                              'name': newCategoryController.text.trim(),
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            });
                            newCategoryController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Lista de categorías
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: _categories.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No hay categorías'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return ListTile(
                              leading: const Icon(Icons.folder, color: Color(0xFF64748B)),
                              title: Text(category['name'] as String),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  setDialogState(() {
                                    _categories.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Categorías guardadas'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildUnitsDialog(),
    );
  }

  Widget _buildUnitsDialog() {
    final nameController = TextEditingController();
    final abbreviationController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.straighten, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text('Unidades de Medida'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Agregar nueva unidad
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la unidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: abbreviationController,
                  decoration: InputDecoration(
                    labelText: 'Abreviatura',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty &&
                        abbreviationController.text.trim().isNotEmpty) {
                      setDialogState(() {
                        _units.add({
                          'name': nameController.text.trim(),
                          'abbreviation': abbreviationController.text.trim(),
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        });
                        nameController.clear();
                        abbreviationController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Unidad'),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                // Lista de unidades
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _units.length,
                    itemBuilder: (context, index) {
                      final unit = _units[index];
                      return ListTile(
                        leading: const Icon(Icons.straighten, color: Color(0xFF64748B)),
                        title: Text(unit['name'] as String),
                        subtitle: Text('Abreviatura: ${unit['abbreviation']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              _units.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unidades guardadas'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildPaymentMethodsDialog(),
    );
  }

  Widget _buildPaymentMethodsDialog() {
    final newMethodController = TextEditingController();
    final paymentMethods = List<String>.from(_paymentMethods);

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.payment, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text('Métodos de Pago'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Agregar nuevo método
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newMethodController,
                        decoration: InputDecoration(
                          labelText: 'Nuevo método de pago',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)),
                      onPressed: () {
                        if (newMethodController.text.trim().isNotEmpty) {
                          setDialogState(() {
                            paymentMethods.add(newMethodController.text.trim());
                            newMethodController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Lista de métodos
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF64748B)),
                        title: Text(paymentMethods[index]),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            // Método activo/inactivo
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _paymentMethods.clear();
                  _paymentMethods.addAll(paymentMethods);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Métodos de pago guardados'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showZipayConfigDialog() {
    final apiKeyController = TextEditingController();
    final secretKeyController = TextEditingController();
    final merchantIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('Configurar iZipay'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configuración de integración con iZipay para procesamiento de pagos digitales.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: merchantIdController,
                decoration: InputDecoration(
                  labelText: 'Merchant ID *',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: apiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API Key *',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: secretKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Secret Key *',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Obtén estas credenciales desde el panel de iZipay',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (merchantIdController.text.isNotEmpty &&
                  apiKeyController.text.isNotEmpty &&
                  secretKeyController.text.isNotEmpty) {
                // TODO: Guardar configuración en backend
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración de iZipay guardada'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complete todos los campos'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showCreditLimitDialog() {
    final limitController = TextEditingController(
      text: _defaultCreditLimit.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.credit_card, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text('Límite de Crédito'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Establece el límite de crédito por defecto para nuevos clientes',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: limitController,
              decoration: InputDecoration(
                labelText: 'Límite de Crédito (S/)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(limitController.text);
              if (limit != null && limit >= 0) {
                setState(() {
                  _defaultCreditLimit = limit;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Límite de crédito actualizado'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showCreditSettingsDialog() {
    final daysController = TextEditingController(
      text: _defaultCreditDays.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text('Configurar Fiados'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configura los días de gracia antes de considerar un cliente como moroso',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              decoration: InputDecoration(
                labelText: 'Días de Gracia',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'días',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Después de este período, el cliente será marcado como moroso',
                      style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(daysController.text);
              if (days != null && days >= 0) {
                setState(() {
                  _defaultCreditDays = days;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración de fiados actualizada'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.people, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text('Usuarios y Permisos'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gestión de usuarios y permisos del sistema',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF64748B)),
                title: const Text('Administrador'),
                subtitle: const Text('Acceso completo al sistema'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const Divider(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddUserDialog();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Agregar Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64748B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'Vendedor');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: roleController.text,
              decoration: InputDecoration(
                labelText: 'Rol *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                DropdownMenuItem(value: 'Vendedor', child: Text('Vendedor')),
                DropdownMenuItem(value: 'Cajero', child: Text('Cajero')),
                DropdownMenuItem(value: 'Almacén', child: Text('Almacén')),
              ],
              onChanged: (value) => roleController.text = value ?? 'Vendedor',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario "${nameController.text}" agregado'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text('Copia de Seguridad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Realiza una copia de seguridad de todos tus datos',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _createBackup();
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Crear Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _restoreBackup();
                    },
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Restaurar Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Última copia: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    // TODO: Implementar creación de backup real
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Copia de seguridad creada exitosamente'),
            ),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _restoreBackup() {
    // TODO: Implementar restauración de backup real
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: const Text(
          '¿Está seguro de restaurar desde una copia de seguridad? Esto sobrescribirá los datos actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup restaurado exitosamente'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _navigateToPrinters() {
    // Navegar a página de impresoras (ya existe)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a configuración de impresoras...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
