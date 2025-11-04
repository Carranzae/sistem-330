import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _selectedBrand = 'Todas';
  RangeValues _priceRange = const RangeValues(0, 200);
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  final List<String> _categories = [
    'Todos',
    'Vestidos',
    'Camisas',
    'Pantalones',
    'Zapatos',
    'Accesorios',
  ];
  final List<String> _brands = [
    'Todas',
    'FashionCo',
    'UrbanWear',
    'AthletiX',
    'ClassicLine',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _filteredProducts = _products;
  }

  void _loadProducts() {
    // Simulación de productos
    _products = [
      ProductModel(
        id: '1',
        name: 'Vestido Elegante Rosa',
        price: 89.99,
        description: 'Hermoso vestido elegante para ocasiones especiales',
        imageUrl:
            'https://via.placeholder.com/200x240/EC4899/FFFFFF?text=Vestido',
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Rosa', 'Negro', 'Azul'],
        collection: 'Primavera 2024',
        inStock: true,
        category: 'Vestidos',
        brand: 'FashionCo',
      ),
      ProductModel(
        id: '2',
        name: 'Camisa Casual Blanca',
        price: 45.99,
        description: 'Camisa casual perfecta para el día a día',
        imageUrl:
            'https://via.placeholder.com/200x240/3B82F6/FFFFFF?text=Camisa',
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Blanco', 'Azul', 'Negro'],
        collection: 'Básicos',
        inStock: true,
        category: 'Camisas',
        brand: 'UrbanWear',
      ),
      ProductModel(
        id: '3',
        name: 'Zapatos Deportivos',
        price: 120.00,
        description: 'Zapatos deportivos cómodos y modernos',
        imageUrl:
            'https://via.placeholder.com/200x240/10B981/FFFFFF?text=Zapatos',
        sizes: ['38', '39', '40', '41', '42'],
        colors: ['Negro', 'Blanco', 'Gris'],
        collection: 'Deportivo',
        inStock: true,
        category: 'Zapatos',
        brand: 'AthletiX',
      ),
    ];
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == 'Todos' ||
            product.category == _selectedCategory;
        final matchesSearch = product.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final matchesBrand = _selectedBrand == 'Todas' ||
            (product.brand ?? '') == _selectedBrand;
        final matchesPrice = product.price >= _priceRange.start &&
            product.price <= _priceRange.end;
        return matchesCategory && matchesSearch && matchesBrand && matchesPrice;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Marketplace',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () => context.push('/ropa_calzado/marketplace/checkout'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => _filterProducts(),
                ),
                const SizedBox(height: 16),
                // Filtros de categoría
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterProducts();
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: const Color(0xFFEC4899),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Filtro de marca y rango de precio
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        items: _brands
                            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _selectedBrand = val);
                          _filterProducts();
                        },
                        decoration: InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Precio'),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 200,
                            divisions: 40,
                            labels: RangeLabels(
                              'S/ ${_priceRange.start.toStringAsFixed(0)}',
                              'S/ ${_priceRange.end.toStringAsFixed(0)}',
                            ),
                            onChanged: (values) {
                              setState(() => _priceRange = values);
                              _filterProducts();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Grid de productos
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron productos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push(
                          '/ropa_calzado/marketplace/product/${product.id}',
                        ),
                        onVirtualFitting: () => context.push(
                          '/ropa_calzado/marketplace/virtual-fitting/${product.id}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ropa_calzado/gallery'),
        backgroundColor: const Color(0xFFEC4899),
        child: const Icon(Icons.photo_library, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
