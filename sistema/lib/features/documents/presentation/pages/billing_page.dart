import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

/// Página principal de facturación (Boletas y Facturas)
class BillingPage extends StatefulWidget {
  final String type; // 'boleta' o 'factura'
  
  const BillingPage({
    super.key,
    required this.type,
  });

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  int _selectedTab = 0; // 0: Generar, 1: Historial

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
          child: _buildContent(provider.currentBusinessCategory),
        );
      },
    );
  }

  Widget _buildContent(String category) {
    return Column(
      children: [
        // Header con tabs
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.type == 'boleta'
                          ? const Color(0xFF2563EB).withOpacity(0.1)
                          : const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.type == 'boleta' ? Icons.receipt : Icons.description,
                      color: widget.type == 'boleta'
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF10B981),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.type == 'boleta' ? 'Boleta de Venta' : 'Factura Electrónica',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.type == 'boleta'
                              ? 'Emitir boletas SUNAT'
                              : 'Facturación electrónica',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de impresora
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.print,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
                    ),
                    onPressed: () {
                      _showPrinterDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tabs
              Row(
                children: [
                  _buildTab('Generar', 0),
                  const SizedBox(width: 8),
                  _buildTab('Historial', 1),
                ],
              ),
            ],
          ),
        ),
        
        // Contenido según tab seleccionado
        Expanded(
          child: _selectedTab == 0 
              ? _buildGenerateView(category)
              : _buildHistoryView(),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTab = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.type == 'boleta'
                      ? const Color(0xFF2563EB).withOpacity(0.1)
                      : const Color(0xFF10B981).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? widget.type == 'boleta'
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF10B981)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? widget.type == 'boleta'
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateView(String category) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del negocio
          _buildBusinessInfoCard(category),
          const SizedBox(height: 24),
          
          // Datos del cliente
          _buildClientSection(),
          const SizedBox(height: 24),
          
          // Productos/Servicios
          _buildProductsSection(),
          const SizedBox(height: 24),
          
          // Totales
          _buildTotalsSection(),
          const SizedBox(height: 32),
          
          // Botones de acción
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoCard(String category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.type == 'boleta'
            ? const Color(0xFF2563EB).withOpacity(0.05)
            : const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.type == 'boleta'
              ? const Color(0xFF2563EB).withOpacity(0.2)
              : const Color(0xFF10B981).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.type == 'boleta'
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.type == 'boleta' ? Icons.receipt : Icons.description,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type == 'boleta' 
                      ? 'BOLETA DE VENTA ELECTRÓNICA'
                      : 'FACTURA ELECTRÓNICA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.type == 'boleta'
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Emisión automática conforme a SUNAT',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: const Color(0xFF2563EB),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Datos del Cliente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: widget.type == 'factura' ? 'RUC' : 'DNI / CE',
              hintText: widget.type == 'factura' ? '20123456789' : '12345678',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Razón Social',
              hintText: 'Nombre completo o razón social',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: const Color(0xFF2563EB),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Productos / Servicios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Agregar producto
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de productos (placeholder)
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay productos agregados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toca el botón "Agregar" para incluir productos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', 'S/ 0.00', isBold: false),
          const Divider(height: 24),
          _buildTotalRow('IGV (18%)', 'S/ 0.00', isBold: false),
          const Divider(height: 24),
          _buildTotalRow('TOTAL', 'S/ 0.00', isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 24 : 18,
            fontWeight: FontWeight.w700,
            color: isBold ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Generar documento
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.type == 'boleta'
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send, size: 24),
                const SizedBox(width: 12),
                Text(
                  widget.type == 'boleta' 
                      ? 'Generar Boleta'
                      : 'Generar Factura',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Guardar borrador
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar Borrador'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFF64748B)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 0, // Placeholder
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt,
                color: Color(0xFF2563EB),
              ),
            ),
            title: const Text('001-001-000001'),
            subtitle: const Text('Cliente: Juan Pérez'),
            trailing: const Text('S/ 150.00'),
          ),
        );
      },
    );
  }

  void _showPrinterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Impresora'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Conecta tu impresora de tickets:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.bluetooth, color: Color(0xFF2563EB)),
              title: Text('Impresora Bluetooth'),
              subtitle: Text('Conectar por Bluetooth'),
            ),
            ListTile(
              leading: Icon(Icons.wifi, color: Color(0xFF10B981)),
              title: Text('Impresora WiFi'),
              subtitle: Text('Conectar por red local'),
            ),
            ListTile(
              leading: Icon(Icons.usb, color: Color(0xFFF59E0B)),
              title: Text('Impresora USB'),
              subtitle: Text('Conectar por cable USB'),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscando impresoras...')),
              );
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}

