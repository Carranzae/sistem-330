import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductGalleryPage extends StatefulWidget {
  const ProductGalleryPage({super.key});

  @override
  State<ProductGalleryPage> createState() => _ProductGalleryPageState();
}

class _ProductGalleryPageState extends State<ProductGalleryPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  String _selectedSeason = 'Todas';
  String _selectedSize = 'Todas';
  String _selectedColor = 'Todos';
  RangeValues _priceRange = const RangeValues(0, 200);
  String _sortBy = 'Nombre';
  bool _showFilters = false;

  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Camiseta Básica Premium',
      category: 'Camisetas',
      season: 'Verano',
      price: 29.99,
      originalPrice: 39.99,
      discount: 25,
      imageUrl: 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=Camiseta',
      colors: ['Azul', 'Rojo', 'Blanco', 'Negro'],
      sizes: ['S', 'M', 'L', 'XL'],
      rating: 4.5,
      reviews: 128,
      isNew: false,
      isFeatured: true,
    ),
    Product(
      id: '2',
      name: 'Jeans Slim Fit',
      category: 'Pantalones',
      season: 'Todas',
      price: 79.99,
      originalPrice: 79.99,
      discount: 0,
      imageUrl: 'https://via.placeholder.com/300x400/4ECDC4/FFFFFF?text=Jeans',
      colors: ['Azul', 'Negro'],
      sizes: ['28', '30', '32', '34', '36'],
      rating: 4.2,
      reviews: 89,
      isNew: true,
      isFeatured: false,
    ),
    Product(
      id: '3',
      name: 'Zapatos Deportivos Air',
      category: 'Calzado',
      season: 'Todas',
      price: 129.99,
      originalPrice: 149.99,
      discount: 13,
      imageUrl: 'https://via.placeholder.com/300x400/45B7D1/FFFFFF?text=Zapatos',
      colors: ['Blanco', 'Negro', 'Gris'],
      sizes: ['39', '40', '41', '42', '43', '44'],
      rating: 4.8,
      reviews: 256,
      isNew: false,
      isFeatured: true,
    ),
    Product(
      id: '4',
      name: 'Chaqueta de Invierno',
      category: 'Abrigos',
      season: 'Invierno',
      price: 159.99,
      originalPrice: 199.99,
      discount: 20,
      imageUrl: 'https://via.placeholder.com/300x400/96CEB4/FFFFFF?text=Chaqueta',
      colors: ['Negro', 'Azul marino', 'Gris'],
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      rating: 4.6,
      reviews: 94,
      isNew: false,
      isFeatured: false,
    ),
    Product(
      id: '5',
      name: 'Vestido Floral',
      category: 'Vestidos',
      season: 'Primavera',
      price: 89.99,
      originalPrice: 89.99,
      discount: 0,
      imageUrl: 'https://via.placeholder.com/300x400/FFEAA7/FFFFFF?text=Vestido',
      colors: ['Floral azul', 'Floral rosa', 'Floral verde'],
      sizes: ['XS', 'S', 'M', 'L'],
      rating: 4.4,
      reviews: 67,
      isNew: true,
      isFeatured: true,
    ),
    Product(
      id: '6',
      name: 'Sudadera con Capucha',
      category: 'Sudaderas',
      season: 'Otoño',
      price: 49.99,
      originalPrice: 59.99,
      discount: 17,
      imageUrl: 'https://via.placeholder.com/300x400/DDA0DD/FFFFFF?text=Sudadera',
      colors: ['Gris', 'Negro', 'Azul', 'Rojo'],
      sizes: ['S', 'M', 'L', 'XL'],
      rating: 4.3,
      reviews: 145,
      isNew: false,
      isFeatured: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería de Productos'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFiltersSection(),
          _buildActiveFiltersChips(),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Categoría',
                  _selectedCategory,
                  ['Todos', 'Camisetas', 'Pantalones', 'Calzado', 'Abrigos', 'Vestidos', 'Sudaderas'],
                  (value) => setState(() => _selectedCategory = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  'Temporada',
                  _selectedSeason,
                  ['Todas', 'Primavera', 'Verano', 'Otoño', 'Invierno'],
                  (value) => setState(() => _selectedSeason = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Talla',
                  _selectedSize,
                  ['Todas', 'XS', 'S', 'M', 'L', 'XL', 'XXL', '28', '30', '32', '34', '36', '39', '40', '41', '42', '43', '44'],
                  (value) => setState(() => _selectedSize = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  'Color',
                  _selectedColor,
                  ['Todos', 'Azul', 'Rojo', 'Blanco', 'Negro', 'Gris', 'Verde', 'Rosa'],
                  (value) => setState(() => _selectedColor = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Rango de Precio'),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 300,
            divisions: 30,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildActiveFiltersChips() {
    final activeFilters = <Widget>[];

    if (_selectedCategory != 'Todos') {
      activeFilters.add(_buildFilterChip('Categoría: $_selectedCategory', () {
        setState(() => _selectedCategory = 'Todos');
      }));
    }

    if (_selectedSeason != 'Todas') {
      activeFilters.add(_buildFilterChip('Temporada: $_selectedSeason', () {
        setState(() => _selectedSeason = 'Todas');
      }));
    }

    if (_selectedSize != 'Todas') {
      activeFilters.add(_buildFilterChip('Talla: $_selectedSize', () {
        setState(() => _selectedSize = 'Todas');
      }));
    }

    if (_selectedColor != 'Todos') {
      activeFilters.add(_buildFilterChip('Color: $_selectedColor', () {
        setState(() => _selectedColor = 'Todos');
      }));
    }

    if (_priceRange.start > 0 || _priceRange.end < 200) {
      activeFilters.add(_buildFilterChip(
        'Precio: \$${_priceRange.start.round()}-\$${_priceRange.end.round()}',
        () {
          setState(() => _priceRange = const RangeValues(0, 200));
        },
      ));
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros activos:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: activeFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _getFilteredProducts();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/ropa_calzado/product/${product.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-${product.discount}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product.isNew)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NUEVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product.isFeatured)
                    const Positioned(
                      bottom: 8,
                      right: 8,
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviews})',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        if (product.discount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${product.originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _getFilteredProducts() {
    return _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Todos' || product.category == _selectedCategory;
      final matchesSeason = _selectedSeason == 'Todas' || product.season == _selectedSeason || product.season == 'Todas';
      final matchesSize = _selectedSize == 'Todas' || product.sizes.contains(_selectedSize);
      final matchesColor = _selectedColor == 'Todos' || product.colors.any((color) => color.toLowerCase().contains(_selectedColor.toLowerCase()));
      final matchesPrice = product.price >= _priceRange.start && product.price <= _priceRange.end;

      return matchesSearch && matchesCategory && matchesSeason && matchesSize && matchesColor && matchesPrice;
    }).toList()..sort(_getSortComparator());
  }

  int Function(Product, Product) _getSortComparator() {
    switch (_sortBy) {
      case 'Precio (menor a mayor)':
        return (a, b) => a.price.compareTo(b.price);
      case 'Precio (mayor a menor)':
        return (a, b) => b.price.compareTo(a.price);
      case 'Calificación':
        return (a, b) => b.rating.compareTo(a.rating);
      case 'Más nuevos':
        return (a, b) => b.isNew ? 1 : (a.isNew ? -1 : 0);
      case 'Nombre':
      default:
        return (a, b) => a.name.compareTo(b.name);
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ordenar por',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...[
                'Nombre',
                'Precio (menor a mayor)',
                'Precio (mayor a menor)',
                'Calificación',
                'Más nuevos',
              ].map((option) {
                return ListTile(
                  title: Text(option),
                  leading: Radio<String>(
                    value: option,
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final String season;
  final double price;
  final double originalPrice;
  final int discount;
  final String imageUrl;
  final List<String> colors;
  final List<String> sizes;
  final double rating;
  final int reviews;
  final bool isNew;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.season,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.imageUrl,
    required this.colors,
    required this.sizes,
    required this.rating,
    required this.reviews,
    required this.isNew,
    required this.isFeatured,
  });
}