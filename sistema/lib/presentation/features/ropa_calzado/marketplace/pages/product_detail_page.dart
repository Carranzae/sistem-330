import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';
import '../widgets/size_selector.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_gallery.dart';
import '../widgets/style_suggestions.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? selectedSize;
  String? selectedColor;
  int quantity = 1;
  int currentImageIndex = 0;

  // Datos de ejemplo del producto
  late ProductModel product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    // Simulación de carga de producto
    product = ProductModel(
      id: widget.productId,
      name: 'Vestido Elegante Rosa',
      price: 89.99,
      description: 'Hermoso vestido elegante perfecto para ocasiones especiales. Confeccionado con materiales de alta calidad y diseño moderno.',
      imageUrl: 'https://via.placeholder.com/400x600/EC4899/FFFFFF?text=Vestido+Rosa',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Rosa', 'Negro', 'Azul', 'Blanco'],
      collection: 'Primavera 2024',
      inStock: true,
      category: 'Vestidos',
      images: [
        'https://via.placeholder.com/400x600/EC4899/FFFFFF?text=Vista+1',
        'https://via.placeholder.com/400x600/EC4899/FFFFFF?text=Vista+2',
        'https://via.placeholder.com/400x600/EC4899/FFFFFF?text=Vista+3',
        'https://via.placeholder.com/400x600/EC4899/FFFFFF?text=Vista+4',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // Agregar a favoritos
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              _shareProduct();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería de imágenes del producto
            ProductGallery(
              images: product.images ?? [product.imageUrl],
              onImageChanged: (index) {
                setState(() {
                  currentImageIndex = index;
                });
              },
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica del producto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Colección: ${product.collection}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descripción
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Selector de colores
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ColorSelector(
                    colors: product.colors,
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Selector de tallas
                  const Text(
                    'Talla',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizeSelector(
                    sizes: product.sizes,
                    selectedSize: selectedSize,
                    onSizeSelected: (size) {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Cantidad
                  Row(
                    children: [
                      const Text(
                        'Cantidad',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: quantity > 1 ? () {
                                setState(() {
                                  quantity--;
                                });
                              } : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sugerencias de estilo
                  StyleSuggestions(
                    currentProduct: product,
                    onProductTap: (suggestedProduct) {
                      context.push('/ropa_calzado/product/${suggestedProduct.id}');
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Botón de prueba virtual
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/ropa_calzado/virtual-fitting/${product.id}');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Probar Virtual'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEC4899),
                  side: const BorderSide(color: Color(0xFFEC4899)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Botón de agregar al carrito
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canAddToCart() ? () {
                  _addToCart();
                } : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Agregar al Carrito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canAddToCart() {
    return selectedSize != null && selectedColor != null && product.inStock;
  }

  void _addToCart() {
    if (!_canAddToCart()) return;
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: const Color(0xFFEC4899),
        action: SnackBarAction(
          label: 'Ver Carrito',
          textColor: Colors.white,
          onPressed: () {
            context.push('/ropa_calzado/checkout');
          },
        ),
      ),
    );
  }

  void _shareProduct() {
    // Implementar compartir producto en redes sociales
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Compartir Producto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  icon: Icons.tiktok,
                  label: 'TikTok',
                  onTap: () => _shareToTikTok(),
                ),
                _buildShareButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () => _shareToFacebook(),
                ),
                _buildShareButton(
                  icon: Icons.share,
                  label: 'Instagram',
                  onTap: () => _shareToInstagram(),
                ),
                _buildShareButton(
                  icon: Icons.link,
                  label: 'Copiar Link',
                  onTap: () => _copyLink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFEC4899),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _shareToTikTok() {
    // Implementar compartir a TikTok
    Navigator.pop(context);
  }

  void _shareToFacebook() {
    // Implementar compartir a Facebook
    Navigator.pop(context);
  }

  void _shareToInstagram() {
    // Implementar compartir a Instagram
    Navigator.pop(context);
  }

  void _copyLink() {
    // Implementar copiar enlace
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        backgroundColor: Color(0xFFEC4899),
      ),
    );
  }
}