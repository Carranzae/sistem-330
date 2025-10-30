import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final List<Map<String, dynamic>> _cart = [];
  double _total = 0.0;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cart.add(product);
      _total += product['precio'];
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _total -= _cart[index]['precio'];
      _cart.removeAt(index);
    });
  }

  Future<void> _processSale() async {
    try {
      final saleData = {
        'cliente_id': null, // Cliente opcional
        'productos': _cart,
        'total': _total,
        'metodo_pago': 'Efectivo',
      };
      await ApiService.createSale(saleData);
      setState(() {
        _cart.clear();
        _total = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta procesada con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar venta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildProductSearchSection(),
          ),
          Expanded(
            flex: 1,
            child: _buildCartSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar producto',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 64),
                    Text(product['nombre']),
                    Text('S/ ${product['precio']}'),
                    ElevatedButton(
                      onPressed: () => _addToCart(product),
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartSection() {
    return Column(
      children: [
        const Text(
          'Carrito de Venta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _cart.length,
            itemBuilder: (context, index) {
              final product = _cart[index];
              return ListTile(
                title: Text(product['nombre']),
                subtitle: const Text('Cantidad: 1'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('S/ ${product['precio']}'),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeFromCart(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _processSale,
            child: Text('Cobrar S/ $_total'),
          ),
        ),
      ],
    );
  }
}
