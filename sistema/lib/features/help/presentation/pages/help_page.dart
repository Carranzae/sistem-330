import 'package:flutter/material.dart';
import '../../../../shared/layouts/main_layout.dart';

/// Módulo de Ayuda
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      businessCategory: 'abarrotes',
      businessName: 'Mi Negocio',
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
                      {'title': 'Cómo registrar mi negocio', 'icon': Icons.store},
                      {'title': 'Primera venta paso a paso', 'icon': Icons.point_of_sale},
                      {'title': 'Agregar productos', 'icon': Icons.add_box},
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildHelpSection(
                    'Tutoriales',
                    Icons.play_circle_outline,
                    Colors.purple,
                    [
                      {'title': 'Gestionar inventario', 'icon': Icons.inventory_2},
                      {'title': 'Configurar fiados', 'icon': Icons.credit_card},
                      {'title': 'Generar reportes', 'icon': Icons.analytics},
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildHelpSection(
                    'Soporte',
                    Icons.headset_mic,
                    Colors.green,
                    [
                      {'title': 'Contacto técnico', 'icon': Icons.phone},
                      {'title': 'Preguntas frecuentes', 'icon': Icons.question_answer},
                      {'title': 'Reportar error', 'icon': Icons.bug_report},
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
                () {},
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
}

