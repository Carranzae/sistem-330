import 'package:flutter/material.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: ListView.builder(
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          return ListTile(
            title: const Text('Cliente'),
            subtitle: const Text('Límite de crédito: S/ 0.00'),
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
