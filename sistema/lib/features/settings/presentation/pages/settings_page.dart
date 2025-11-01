import 'package:flutter/material.dart';
import '../../../../shared/layouts/main_layout.dart';

/// Módulo de Configuración
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                        'Gestiona las categorías',
                        Icons.category_outlined,
                        () {},
                      ),
                      _buildSettingTile(
                        'Unidades de Medida',
                        'Configura unidades',
                        Icons.straighten_outlined,
                        () {},
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
                        'Efectivo, Yape, Plin',
                        Icons.account_balance_wallet_outlined,
                        () {},
                      ),
                      _buildSettingTile(
                        'Configurar iZipay',
                        'Integración pagos',
                        Icons.payment_outlined,
                        () {},
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
                        'Configurar créditos',
                        Icons.credit_card_outlined,
                        () {},
                      ),
                      _buildSettingTile(
                        'Configurar Fiados',
                        'Ajustes de morosidad',
                        Icons.schedule_outlined,
                        () {},
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
                        () {},
                      ),
                      _buildSettingTile(
                        'Copia de Seguridad',
                        'Respaldo de datos',
                        Icons.backup_outlined,
                        () {},
                      ),
                      _buildSettingTile(
                        'Impresoras',
                        'Configurar impresión',
                        Icons.print_outlined,
                        () {},
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
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
}

