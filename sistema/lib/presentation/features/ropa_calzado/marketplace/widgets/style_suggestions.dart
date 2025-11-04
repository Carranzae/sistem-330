import 'package:flutter/material.dart';
import '../models/product_model.dart';

class StyleSuggestions extends StatelessWidget {
  final ProductModel currentProduct;
  final Function(ProductModel) onProductTap;

  const StyleSuggestions({
    Key? key,
    required this.currentProduct,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suggestions = _getSuggestions();
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Combina Perfecto Con',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sugerencias de estilo personalizadas para ti',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => onProductTap(suggestion),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto sugerido
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            suggestion.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFFEC4899),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Nombre del producto
                      Text(
                        suggestion.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Precio
                      Text(
                        '\$${suggestion.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<ProductModel> _getSuggestions() {
    // Simulación de sugerencias basadas en el producto actual
    // En una implementación real, esto vendría de un algoritmo de recomendación
    
    final suggestions = <ProductModel>[];
    
    // Sugerencias basadas en la categoría del producto actual
    if (currentProduct.category == 'Vestidos') {
      suggestions.addAll([
        ProductModel(
          id: 'sugg_1',
          name: 'Zapatos Elegantes',
          price: 65.99,
          description: 'Zapatos perfectos para complementar tu vestido',
          imageUrl: 'https://via.placeholder.com/200x250/8B5CF6/FFFFFF?text=Zapatos',
          sizes: ['36', '37', '38', '39', '40'],
          colors: ['Negro', 'Nude', 'Rosa'],
          collection: 'Primavera 2024',
          inStock: true,
          category: 'Zapatos',
        ),
        ProductModel(
          id: 'sugg_2',
          name: 'Bolso de Mano',
          price: 45.99,
          description: 'Bolso elegante que combina perfectamente',
          imageUrl: 'https://via.placeholder.com/200x250/F59E0B/FFFFFF?text=Bolso',
          sizes: ['Único'],
          colors: ['Negro', 'Rosa', 'Dorado'],
          collection: 'Primavera 2024',
          inStock: true,
          category: 'Accesorios',
        ),
        ProductModel(
          id: 'sugg_3',
          name: 'Collar Delicado',
          price: 29.99,
          description: 'Collar que realza tu look elegante',
          imageUrl: 'https://via.placeholder.com/200x250/10B981/FFFFFF?text=Collar',
          sizes: ['Único'],
          colors: ['Dorado', 'Plateado', 'Rosa Gold'],
          collection: 'Primavera 2024',
          inStock: true,
          category: 'Joyería',
        ),
      ]);
    } else if (currentProduct.category == 'Zapatos') {
      suggestions.addAll([
        ProductModel(
          id: 'sugg_4',
          name: 'Vestido Casual',
          price: 55.99,
          description: 'Vestido perfecto para usar con estos zapatos',
          imageUrl: 'https://via.placeholder.com/200x250/EC4899/FFFFFF?text=Vestido',
          sizes: ['XS', 'S', 'M', 'L', 'XL'],
          colors: ['Azul', 'Blanco', 'Rosa'],
          collection: 'Primavera 2024',
          inStock: true,
          category: 'Vestidos',
        ),
      ]);
    }
    
    return suggestions;
  }
}