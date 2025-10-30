import 'package:flutter/material.dart';

class CashPage extends StatelessWidget {
  const CashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Estado de Caja'),
            subtitle: const Text('ABIERTA'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Cerrar Caja'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Placeholder
              itemBuilder: (context, index) {
                return ListTile(
                  title: const Text('Movimiento'),
                  subtitle: const Text('S/ 0.00'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
