import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';

class SocialShareWidget extends StatelessWidget {
  final ProductModel product;
  final String storeUrl;

  const SocialShareWidget({
    Key? key,
    required this.product,
    this.storeUrl = 'https://mitienda.com',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Compartir Producto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Product preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (product.isOnSale) ...[
                            Text(
                              'S/ ${product.originalPrice?.toStringAsFixed(2)}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            'S/ ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFEC4899),
                            ),
                          ),
                          if (product.isOnSale) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.discountText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Social media options
          const Text(
            'Compartir en:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Social media grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildSocialButton(
                context,
                icon: Icons.video_camera_front,
                label: 'TikTok',
                color: const Color(0xFF000000),
                onTap: () => _shareToTikTok(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: () => _shareToInstagram(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => _shareToFacebook(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.message,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareToWhatsApp(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.alternate_email,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: () => _shareToTwitter(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.telegram,
                label: 'Telegram',
                color: const Color(0xFF0088CC),
                onTap: () => _shareToTelegram(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.email,
                label: 'Email',
                color: const Color(0xFF34495E),
                onTap: () => _shareByEmail(context),
              ),
              _buildSocialButton(
                context,
                icon: Icons.link,
                label: 'Copiar Link',
                color: const Color(0xFF6C757D),
                onTap: () => _copyLink(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Generate promotional content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEC4899).withOpacity(0.1),
                  const Color(0xFFEC4899).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEC4899).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFFEC4899),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Contenido Promocional',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Genera contenido automático para tus redes sociales con hashtags y descripciones optimizadas.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _generateContent(context, 'story'),
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: const Text('Story'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEC4899),
                          side: const BorderSide(color: Color(0xFFEC4899)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _generateContent(context, 'post'),
                        icon: const Icon(Icons.post_add, size: 16),
                        label: const Text('Post'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEC4899),
                          side: const BorderSide(color: Color(0xFFEC4899)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _generateContent(context, 'video'),
                        icon: const Icon(Icons.videocam, size: 16),
                        label: const Text('Video'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEC4899),
                          side: const BorderSide(color: Color(0xFFEC4899)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _generateShareText() {
    String text = '¡Mira este increíble ${product.name}! ✨\n\n';
    
    if (product.isOnSale) {
      text += '🔥 ¡OFERTA ESPECIAL! ${product.discountText} de descuento\n';
      text += '💰 Antes: S/ ${product.originalPrice?.toStringAsFixed(2)}\n';
    }
    
    text += '💸 Precio: S/ ${product.price.toStringAsFixed(2)}\n';
    text += '⭐ Calificación: ${(product.rating ?? 0).toString()}/5 (${product.reviewCount ?? 0} reseñas)\n\n';
    
    text += '📱 Compra ahora en nuestra tienda online:\n';
    text += '$storeUrl/product/${product.id}\n\n';
    
    // Add hashtags based on product
    List<String> hashtags = [
      '#moda',
      '#fashion',
      '#style',
      '#${product.category.toLowerCase().replaceAll(' ', '')}',
      '#${product.collection.toLowerCase().replaceAll(' ', '')}',
      ...(product.tags ?? []).map((tag) => '#$tag'),
    ];
    
    if (product.isOnSale) {
      hashtags.addAll(['#oferta', '#descuento', '#promocion']);
    }
    
    text += hashtags.take(10).join(' ');
    
    return text;
  }

  String _generateProductUrl() {
    return '$storeUrl/product/${product.id}';
  }

  void _shareToTikTok(BuildContext context) {
    final text = _generateShareText();
    _showSharePreview(context, 'TikTok', text, 'tiktok://');
  }

  void _shareToInstagram(BuildContext context) {
    final text = _generateShareText();
    _showSharePreview(context, 'Instagram', text, 'instagram://');
  }

  void _shareToFacebook(BuildContext context) {
    final url = _generateProductUrl();
    final text = 'Mira este increíble ${product.name} en nuestra tienda!';
    _showSharePreview(context, 'Facebook', '$text\n\n$url', 'fb://');
  }

  void _shareToWhatsApp(BuildContext context) {
    final text = _generateShareText();
    _showSharePreview(context, 'WhatsApp', text, 'whatsapp://send?text=');
  }

  void _shareToTwitter(BuildContext context) {
    final text = _generateShareText();
    final limitedText = text.length > 280 ? '${text.substring(0, 277)}...' : text;
    _showSharePreview(context, 'Twitter', limitedText, 'twitter://post?message=');
  }

  void _shareToTelegram(BuildContext context) {
    final text = _generateShareText();
    _showSharePreview(context, 'Telegram', text, 'tg://msg?text=');
  }

  void _shareByEmail(BuildContext context) {
    final subject = 'Mira este producto: ${product.name}';
    final body = _generateShareText();
    _showSharePreview(context, 'Email', '$subject\n\n$body', 'mailto:?subject=$subject&body=');
  }

  void _copyLink(BuildContext context) {
    final url = _generateProductUrl();
    Clipboard.setData(ClipboardData(text: url));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Enlace copiado al portapapeles!'),
          ],
        ),
        backgroundColor: const Color(0xFFEC4899),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSharePreview(BuildContext context, String platform, String content, String scheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Compartir en $platform'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contenido a compartir:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Se abrirá la app de $platform para compartir',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí se abriría la app correspondiente
              _simulateAppLaunch(context, platform);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
            ),
            child: const Text(
              'Compartir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateAppLaunch(BuildContext context, String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.launch, color: Colors.white),
            const SizedBox(width: 8),
            Text('Abriendo $platform...'),
          ],
        ),
        backgroundColor: const Color(0xFFEC4899),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _generateContent(BuildContext context, String type) {
    String title = '';
    String content = '';
    
    switch (type) {
      case 'story':
        title = 'Contenido para Story';
        content = _generateStoryContent();
        break;
      case 'post':
        title = 'Contenido para Post';
        content = _generatePostContent();
        break;
      case 'video':
        title = 'Script para Video';
        content = _generateVideoScript();
        break;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Personaliza este contenido según tu estilo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Contenido copiado al portapapeles!'),
                  backgroundColor: Color(0xFFEC4899),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
            ),
            child: const Text(
              'Copiar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _generateStoryContent() {
    return '''🔥 ¡NUEVO EN LA TIENDA! 🔥

${product.name}

${product.isOnSale ? '💥 ${product.discountText} OFF' : ''}
💰 S/ ${product.price.toStringAsFixed(2)}
⭐ ${(product.rating ?? 0).toString()}/5

¡Desliza hacia arriba para comprarlo! 👆

#moda #fashion #${product.category.toLowerCase()}''';
  }

  String _generatePostContent() {
    return '''✨ Presentamos: ${product.name} ✨

${product.description}

${product.isOnSale ? '🎉 ¡OFERTA ESPECIAL! ${product.discountText} de descuento\n💸 Antes: S/ ${product.originalPrice?.toStringAsFixed(2)}\n' : ''}💰 Precio: S/ ${product.price.toStringAsFixed(2)}
⭐ Calificación: ${(product.rating ?? 0).toString()}/5 (${product.reviewCount ?? 0} reseñas)

📦 Disponible en tallas: ${product.sizes.join(', ')}
🎨 Colores: ${product.colors.join(', ')}

🛒 ¡Compra ahora en nuestra tienda online!
📱 Link en bio

${_generateHashtags().join(' ')}''';
  }

  String _generateVideoScript() {
    return '''🎬 SCRIPT PARA VIDEO - ${product.name}

INTRO (0-3s):
"¡Hola! ¿Buscas ${product.category.toLowerCase()}? ¡Tengo algo perfecto para ti!"

PRODUCTO (3-10s):
"Mira este increíble ${product.name}"
[Mostrar el producto desde diferentes ángulos]

CARACTERÍSTICAS (10-15s):
"Disponible en tallas ${product.sizes.join(', ')}"
"Múltiples colores para elegir"
${product.isOnSale ? '"¡Y ahora con ${product.discountText} de descuento!"' : ''}

PRECIO (15-18s):
${product.isOnSale ? '"Antes S/ ${product.originalPrice?.toStringAsFixed(2)}, ahora solo S/ ${product.price.toStringAsFixed(2)}"' : '"Solo S/ ${product.price.toStringAsFixed(2)}"'}

CALL TO ACTION (18-20s):
"¡Compra ahora! Link en mi bio"
"¡No te quedes sin el tuyo!"

HASHTAGS:
${_generateHashtags().take(5).join(' ')}''';
  }

  List<String> _generateHashtags() {
    return [
      '#moda',
      '#fashion',
      '#style',
      '#${product.category.toLowerCase().replaceAll(' ', '')}',
      '#${product.collection.toLowerCase().replaceAll(' ', '')}',
      ...(product.tags ?? []).map((tag) => '#$tag'),
      if (product.isOnSale) ...[
        '#oferta',
        '#descuento',
        '#promocion',
      ],
      '#tiendaonline',
      '#compraahora',
    ];
  }
}

// Widget para mostrar el botón de compartir
class ShareButton extends StatelessWidget {
  final ProductModel product;
  final String? storeUrl;

  const ShareButton({
    Key? key,
    required this.product,
    this.storeUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SocialShareWidget(
            product: product,
            storeUrl: storeUrl ?? 'https://mitienda.com',
          ),
        );
      },
      icon: const Icon(Icons.share),
      tooltip: 'Compartir producto',
    );
  }
}