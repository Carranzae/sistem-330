import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../shared/layouts/main_layout.dart';

class ProvidersPage extends StatelessWidget {
  const ProvidersPage({super.key});

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
          child: _buildProvidersContent(),
        );
      },
    );
  }

  Widget _buildProvidersContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView.builder(
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: const Text('Proveedor'),
              subtitle: const Text('Deuda: S/ 0.00'),
              trailing: const Icon(Icons.arrow_forward),
            ),
          );
        },
      ),
    );
  }
}
