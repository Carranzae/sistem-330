import 'package:flutter/material.dart';

class ProvidersPage extends StatelessWidget {
  const ProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
      ),
      body: ListView.builder(
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          return ListTile(
            title: const Text('Proveedor'),
            subtitle: const Text('Deuda: S/ 0.00'),
            trailing: const Icon(Icons.arrow_forward),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
