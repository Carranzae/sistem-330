import 'package:flutter/material.dart';
import '../models/product_model.dart';

class OutfitSuggestions extends StatefulWidget {
  final ProductModel currentProduct;
  final Function(ProductModel) onProductTap;

  const OutfitSuggestions({
    Key? key,
    required this.currentProduct,
    required this.onProductTap,
  }) : super(key: key);

  @override
  State<OutfitSuggestions> createState() => _OutfitSuggestionsState();
}

class _OutfitSuggestionsState extends State<OutfitSuggestions> {
  List<OutfitCombination> outfitSuggestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateOutfitSuggestions();
  }

  void _generateOutfitSuggestions() {
    // Simular carga de sugerencias de IA
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        outfitSuggestions = _getOutfitSuggestions(widget.currentProduct);
        isLoading = false;
      });
    });
  }

  List<OutfitCombination> _getOutfitSuggestions(ProductModel product) {
    // Simulación de sugerencias basadas en el producto actual
    return [
      OutfitCombination(
        id: '1',
        name: 'Look Casual Chic',
        description: 'Perfecto para el día a día con un toque elegante',
        occasion: 'Casual',
        season: 'Primavera',
        styleScore: 95,
        products: [
          widget.currentProduct,
          ProductModel(
            id: 'complement1',
            name: 'Jeans Skinny Azul',
            price: 89.90,
            description: 'Jeans de corte moderno',
            category: 'Pantalones',
            imageUrl: 'https://via.placeholder.com/300x400',
            images: ['https://via.placeholder.com/300x400'],
            sizes: ['S', 'M', 'L'],
            colors: ['Azul'],
            collection: 'Básicos',
            inStock: true,
          ),
          ProductModel(
            id: 'complement2',
            name: 'Zapatillas Blancas',
            price: 129.90,
            description: 'Zapatillas deportivas elegantes',
            category: 'Calzado',
            imageUrl: 'https://via.placeholder.com/300x400',
            images: ['https://via.placeholder.com/300x400'],
            sizes: ['36', '37', '38', '39'],
            colors: ['Blanco'],
            collection: 'Deportivo',
            inStock: true,
          ),
        ],
        tags: ['Cómodo', 'Versátil', 'Moderno'],
      ),
      OutfitCombination(
        id: '2',
        name: 'Elegancia Nocturna',
        description: 'Ideal para cenas y eventos especiales',
        occasion: 'Formal',
        season: 'Todo el año',
        styleScore: 88,
        products: [
          widget.currentProduct,
          ProductModel(
            id: 'complement3',
            name: 'Falda Midi Negra',
            price: 79.90,
            description: 'Falda elegante de corte midi',
            category: 'Faldas',
            imageUrl: 'https://via.placeholder.com/300x400',
            images: ['https://via.placeholder.com/300x400'],
            sizes: ['S', 'M', 'L'],
            colors: ['Negro'],
            collection: 'Elegante',
            inStock: true,
          ),
          ProductModel(
            id: 'complement4',
            name: 'Tacones Negros',
            price: 149.90,
            description: 'Tacones clásicos de altura media',
            category: 'Calzado',
            imageUrl: 'https://via.placeholder.com/300x400',
            images: ['https://via.placeholder.com/300x400'],
            sizes: ['36', '37', '38', '39'],
            colors: ['Negro'],
            collection: 'Elegante',
            inStock: true,
          ),
        ],
        tags: ['Elegante', 'Sofisticado', 'Atemporal'],
      ),
      OutfitCombination(
        id: '3',
        name: 'Vibes de Verano',
        description: 'Fresco y colorido para días soleados',
        occasion: 'Playa/Vacaciones',
        season: 'Verano',
        styleScore: 92,
        products: [
          widget.currentProduct,
          ProductModel(
            id: 'complement5',
            name: 'Short de Lino Beige',
            price: 59.90,
            description: 'Short cómodo de lino natural',
            category: 'Shorts',
            imageUrl: 'https://via.placeholder.com/300x400',
            images: ['https://via.placeholder.com/300x400'],
            sizes: ['S', 'M', 'L'],
            colors: ['Beige'],
            collection: 'Verano',
            inStock: true,
          ),
          ProductModel(
            id: 'complement6',
            name: 'Sandalias de Cuero',
            price: 89.90,
            description: 'Sandalias artesanales de cuero',
            category: 'Calzado',
            imageUrl: 'https://via.placeholder.com/300x400',
            images: ['https://via.placeholder.com/300x400'],
            sizes: ['36', '37', '38', '39'],
            colors: ['Marrón'],
            collection: 'Verano',
            inStock: true,
          ),
        ],
        tags: ['Fresco', 'Cómodo', 'Playero'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFFEC4899),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Outfits Sugeridos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 16,
                    color: const Color(0xFFEC4899),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'IA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEC4899),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Combinaciones perfectas para tu estilo',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (isLoading)
          _buildLoadingState()
        else
          _buildOutfitsList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFFEC4899),
            ),
            const SizedBox(height: 16),
            Text(
              'Generando outfits perfectos...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitsList() {
    return Column(
      children: outfitSuggestions.map((outfit) => _buildOutfitCard(outfit)).toList(),
    );
  }

  Widget _buildOutfitCard(OutfitCombination outfit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del outfit
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        outfit.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(outfit.styleScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: _getScoreColor(outfit.styleScore),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${outfit.styleScore}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(outfit.styleScore),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información del outfit
            Row(
              children: [
                _buildInfoChip(Icons.event, outfit.occasion),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.wb_sunny, outfit.season),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Productos del outfit
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: outfit.products.length,
                itemBuilder: (context, index) {
                  final product = outfit.products[index];
                  final isCurrentProduct = product.id == widget.currentProduct.id;
                  
                  return GestureDetector(
                    onTap: () => widget.onProductTap(product),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isCurrentProduct
                                  ? Border.all(
                                      color: const Color(0xFFEC4899),
                                      width: 2,
                                    )
                                  : null,
                              image: DecorationImage(
                                image: NetworkImage(
                                  product.images?.first ?? product.imageUrl,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: isCurrentProduct
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFFEC4899).withOpacity(0.2),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFEC4899),
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrentProduct ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentProduct ? const Color(0xFFEC4899) : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tags y precio total
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: outfit.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Precio total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'S/ ${outfit.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareOutfit(outfit),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEC4899),
                      side: const BorderSide(color: Color(0xFFEC4899)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addOutfitToCart(outfit),
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Agregar Todo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFFEC4899),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFEC4899),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }

  void _shareOutfit(OutfitCombination outfit) {
    // Implementar compartir outfit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo outfit: ${outfit.name}'),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
  }

  void _addOutfitToCart(OutfitCombination outfit) {
    // Implementar agregar outfit completo al carrito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Outfit "${outfit.name}" agregado al carrito'),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
  }
}

class OutfitCombination {
  final String id;
  final String name;
  final String description;
  final String occasion;
  final String season;
  final int styleScore;
  final List<ProductModel> products;
  final List<String> tags;

  OutfitCombination({
    required this.id,
    required this.name,
    required this.description,
    required this.occasion,
    required this.season,
    required this.styleScore,
    required this.products,
    required this.tags,
  });

  double get totalPrice {
    return products.fold(0.0, (sum, product) => sum + product.price);
  }

  double get totalOriginalPrice {
    return products.fold(0.0, (sum, product) => sum + (product.originalPrice ?? product.price));
  }

  double get totalDiscount {
    return totalOriginalPrice - totalPrice;
  }

  bool get hasDiscount {
    return totalDiscount > 0;
  }
}