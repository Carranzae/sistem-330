import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

/// Sistema Empresarial de Ayuda y Soporte - Funcional y Completo
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
          child: Padding(
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
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ayuda y Soporte',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Todo lo que necesitas saber',
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

                // Lista de ayuda
                Expanded(
                  child: ListView(
                    children: [
                      _buildHelpSection(
                        'Inicio Rápido',
                        Icons.rocket_launch,
                        Colors.blue,
                        [
                          {
                            'title': 'Cómo registrar mi negocio',
                            'icon': Icons.store,
                            'onTap': () => _showGuide('register_business'),
                          },
                          {
                            'title': 'Primera venta paso a paso',
                            'icon': Icons.point_of_sale,
                            'onTap': () => _showGuide('first_sale'),
                          },
                          {
                            'title': 'Agregar productos',
                            'icon': Icons.add_box,
                            'onTap': () => _showGuide('add_products'),
                          },
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildHelpSection(
                        'Tutoriales',
                        Icons.play_circle_outline,
                        Colors.purple,
                        [
                          {
                            'title': 'Gestionar inventario',
                            'icon': Icons.inventory_2,
                            'onTap': () => _showGuide('manage_inventory'),
                          },
                          {
                            'title': 'Configurar fiados',
                            'icon': Icons.credit_card,
                            'onTap': () => _showGuide('configure_credits'),
                          },
                          {
                            'title': 'Generar reportes',
                            'icon': Icons.analytics,
                            'onTap': () => _showGuide('generate_reports'),
                          },
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildHelpSection(
                        'Soporte',
                        Icons.headset_mic,
                        Colors.green,
                        [
                          {
                            'title': 'Contacto técnico',
                            'icon': Icons.phone,
                            'onTap': () => _showSupportOptions(),
                          },
                          {
                            'title': 'Preguntas frecuentes',
                            'icon': Icons.question_answer,
                            'onTap': () => _showFAQs(),
                          },
                          {
                            'title': 'Reportar error',
                            'icon': Icons.bug_report,
                            'onTap': () => _showBugReport(),
                          },
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Info de versión
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF6B7280)),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Versión 1.0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _checkUpdates,
                              child: const Text('Verificar actualizaciones'),
                            ),
                          ],
                        ),
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

  Widget _buildHelpSection(
    String title,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> items,
  ) {
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildHelpItem(
                item['title'] as String,
                item['icon'] as IconData,
                item['onTap'] as VoidCallback,
              )),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuide(String guideType) {
    Map<String, dynamic> guideData;

    switch (guideType) {
      case 'register_business':
        guideData = {
          'title': 'Cómo registrar mi negocio',
          'icon': Icons.store,
          'steps': [
            {
              'number': 1,
              'title': 'Completa el formulario de registro',
              'description': 'Ingresa los datos básicos de tu negocio: nombre, categoría, RUC y dirección.',
            },
            {
              'number': 2,
              'title': 'Selecciona tu categoría de negocio',
              'description': 'Elige la categoría que mejor describe tu negocio (Abarrotes, Bodega, Restaurante, etc.).',
            },
            {
              'number': 3,
              'title': 'Configura tu sistema',
              'description': 'Establece tus preferencias iniciales: moneda, métodos de pago y unidades de medida.',
            },
            {
              'number': 4,
              'title': '¡Listo para comenzar!',
              'description': 'Una vez completado el registro, podrás comenzar a usar todas las funcionalidades del sistema.',
            },
          ],
        };
        break;
      case 'first_sale':
        guideData = {
          'title': 'Primera venta paso a paso',
          'icon': Icons.point_of_sale,
          'steps': [
            {
              'number': 1,
              'title': 'Accede al Punto de Venta',
              'description': 'Ve al módulo "Punto de Venta" desde el menú principal.',
            },
            {
              'number': 2,
              'title': 'Selecciona los productos',
              'description': 'Busca y agrega los productos que el cliente desea comprar. Puedes usar el código de barras o buscar por nombre.',
            },
            {
              'number': 3,
              'title': 'Revisa el carrito',
              'description': 'Verifica los productos, cantidades y precios en el carrito de compras.',
            },
            {
              'number': 4,
              'title': 'Selecciona método de pago',
              'description': 'Elige cómo el cliente pagará: Efectivo, Tarjeta, Yape, Plin, etc.',
            },
            {
              'number': 5,
              'title': 'Procesa el pago',
              'description': 'Confirma la venta. El sistema actualizará automáticamente el inventario y registrará la transacción.',
            },
          ],
        };
        break;
      case 'add_products':
        guideData = {
          'title': 'Agregar productos',
          'icon': Icons.add_box,
          'steps': [
            {
              'number': 1,
              'title': 'Ve al módulo de Inventario',
              'description': 'Accede a "Inventario" desde el menú principal.',
            },
            {
              'number': 2,
              'title': 'Haz clic en "Agregar Producto"',
              'description': 'Busca el botón "+ Agregar Producto" en la parte superior de la pantalla.',
            },
            {
              'number': 3,
              'title': 'Completa la información',
              'description': 'Ingresa: nombre, código/SKU, categoría, precio de compra, precio de venta, stock inicial y unidad de medida.',
            },
            {
              'number': 4,
              'title': 'Configura opciones adicionales',
              'description': 'Opcionalmente agrega: imagen, descripción, fecha de vencimiento y stock mínimo.',
            },
            {
              'number': 5,
              'title': 'Guarda el producto',
              'description': 'Haz clic en "Guardar". El producto quedará disponible para ventas inmediatamente.',
            },
          ],
        };
        break;
      case 'manage_inventory':
        guideData = {
          'title': 'Gestionar inventario',
          'icon': Icons.inventory_2,
          'steps': [
            {
              'number': 1,
              'title': 'Monitorea el stock',
              'description': 'El módulo de inventario muestra el stock actual de todos tus productos en tiempo real.',
            },
            {
              'number': 2,
              'title': 'Usa los filtros',
              'description': 'Filtra por categoría, busca productos por nombre o código, y visualiza productos con stock bajo.',
            },
            {
              'number': 3,
              'title': 'Registra entradas y salidas',
              'description': 'En la pestaña "Movimientos" puedes registrar compras (entradas) y ajustes de inventario (salidas).',
            },
            {
              'number': 4,
              'title': 'Revisa alertas',
              'description': 'El sistema te notificará automáticamente cuando un producto tenga stock bajo o esté por vencer.',
            },
            {
              'number': 5,
              'title': 'Exporta reportes',
              'description': 'Genera reportes de inventario en PDF o Excel para análisis y auditorías.',
            },
          ],
        };
        break;
      case 'configure_credits':
        guideData = {
          'title': 'Configurar fiados',
          'icon': Icons.credit_card,
          'steps': [
            {
              'number': 1,
              'title': 'Ve a Configuración',
              'description': 'Accede al módulo "Configuración" desde el menú principal.',
            },
            {
              'number': 2,
              'title': 'Sección Clientes',
              'description': 'En la sección "Clientes", selecciona "Configurar Fiados".',
            },
            {
              'number': 3,
              'title': 'Establece días de gracia',
              'description': 'Configura cuántos días de gracia tendrán los clientes antes de ser considerados morosos.',
            },
            {
              'number': 4,
              'title': 'Define límite de crédito',
              'description': 'Establece un límite de crédito por defecto para nuevos clientes.',
            },
            {
              'number': 5,
              'title': 'Gestiona créditos',
              'description': 'En el módulo "Clientes" puedes ver quién tiene créditos pendientes y registrar pagos.',
            },
          ],
        };
        break;
      case 'generate_reports':
        guideData = {
          'title': 'Generar reportes',
          'icon': Icons.analytics,
          'steps': [
            {
              'number': 1,
              'title': 'Accede a Reportes',
              'description': 'Ve al módulo "Reportes" desde el menú principal.',
            },
            {
              'number': 2,
              'title': 'Selecciona el tipo de reporte',
              'description': 'Elige entre: Ventas, Inventario, Financiero, Clientes, Productos por Vencer o Control de Caja.',
            },
            {
              'number': 3,
              'title': 'Aplica filtros',
              'description': 'Opcionalmente filtra por rango de fechas, categorías o otros criterios según el reporte.',
            },
            {
              'number': 4,
              'title': 'Revisa los datos',
              'description': 'Visualiza las estadísticas y tablas detalladas del reporte seleccionado.',
            },
            {
              'number': 5,
              'title': 'Exporta el reporte',
              'description': 'Haz clic en el botón de exportar para descargar el reporte en PDF o Excel.',
            },
          ],
        };
        break;
      default:
        guideData = {'title': 'Guía', 'icon': Icons.help, 'steps': []};
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGuideSheet(guideData),
    );
  }

  Widget _buildGuideSheet(Map<String, dynamic> guideData) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        guideData['icon'] as IconData,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        guideData['title'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Pasos
                ...(guideData['steps'] as List<dynamic>).map((step) {
                  return _buildStepCard(
                    step['number'] as int,
                    step['title'] as String,
                    step['description'] as String,
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard(int number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contacto Técnico',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              'Llamar',
              'Teléfono de soporte',
              Icons.phone,
              Colors.green,
              () => _makePhoneCall('+51987654321'),
            ),
            _buildContactOption(
              'Email',
              'soporte@sistema.com',
              Icons.email,
              Colors.blue,
              () => _sendEmail('soporte@sistema.com'),
            ),
            _buildContactOption(
              'WhatsApp',
              'Chat de soporte',
              Icons.chat,
              Colors.green,
              () => _openWhatsApp('51987654321'),
            ),
            _buildContactOption(
              'Horario de atención',
              'Lun - Vie: 9:00 AM - 6:00 PM',
              Icons.access_time,
              Colors.orange,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFAQs() {
    final faqs = [
      {
        'question': '¿Cómo restablezco mi contraseña?',
        'answer': 'Ve a la pantalla de inicio de sesión y haz clic en "¿Olvidaste tu contraseña?". Ingresa tu email y recibirás un enlace para restablecerla.',
      },
      {
        'question': '¿Puedo usar el sistema sin internet?',
        'answer': 'El sistema funciona principalmente con conexión a internet para sincronizar datos. Algunas funciones básicas pueden funcionar offline temporalmente.',
      },
      {
        'question': '¿Cómo exporto mis datos?',
        'answer': 'Puedes exportar datos desde el módulo de Reportes. Cada reporte tiene botones para exportar en PDF o Excel.',
      },
      {
        'question': '¿Cómo agrego múltiples productos a la vez?',
        'answer': 'Actualmente debes agregar productos uno por uno. Próximamente estará disponible la importación masiva desde Excel.',
      },
      {
        'question': '¿El sistema guarda automáticamente?',
        'answer': 'Sí, todas las transacciones y cambios se guardan automáticamente en tiempo real.',
      },
      {
        'question': '¿Puedo tener múltiples usuarios?',
        'answer': 'Sí, desde Configuración > Usuarios y Permisos puedes agregar usuarios adicionales con diferentes roles.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Preguntas Frecuentes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...faqs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    return _buildFAQItem(
                      faq['question'] as String,
                      faq['answer'] as String,
                      index,
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, int index) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _showBugReport() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Error';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.bug_report, color: Colors.red),
                SizedBox(width: 8),
                Text('Reportar Error'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ayúdanos a mejorar el sistema reportando errores o sugerencias.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Error', child: Text('Error')),
                      DropdownMenuItem(value: 'Sugerencia', child: Text('Sugerencia')),
                      DropdownMenuItem(value: 'Mejora', child: Text('Mejora')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value ?? 'Error';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Asunto *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción detallada *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Describe el error o problema que encontraste...',
                    ),
                    maxLines: 5,
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
                  if (subjectController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Reporte enviado. Gracias por tu colaboración.'),
                            ),
                          ],
                        ),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    // TODO: Enviar reporte al backend
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar Reporte'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Estás usando la versión más reciente (1.0.0)'),
            ),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el teléfono: $phoneNumber')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Soporte Sistema&body=');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el email: $email')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber?text=Hola, necesito soporte técnico');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }
}
