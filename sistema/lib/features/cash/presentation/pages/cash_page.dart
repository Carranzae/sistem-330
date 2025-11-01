import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

class CashPage extends StatelessWidget {
  const CashPage({super.key});

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
          child: _buildCashContent(),
        );
      },
    );
  }

  Widget _buildCashContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: const Text('Estado de Caja'),
              subtitle: const Text('ABIERTA'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Cerrar Caja'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Placeholder
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: const Text('Movimiento'),
                    subtitle: const Text('S/ 0.00'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
