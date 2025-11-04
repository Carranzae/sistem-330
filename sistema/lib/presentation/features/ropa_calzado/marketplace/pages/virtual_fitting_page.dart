import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class VirtualFittingPage extends StatefulWidget {
  final String productId;

  const VirtualFittingPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<VirtualFittingPage> createState() => _VirtualFittingPageState();
}

class _VirtualFittingPageState extends State<VirtualFittingPage>
    with TickerProviderStateMixin {
  bool isCameraActive = false;
  bool isLoading = false;
  bool isRecording = false;
  bool showInstructions = true;
  String selectedCamera = 'front';
  String selectedProduct = '';
  String currentFilter = 'none';
  double zoomLevel = 1.0;
  
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  
  Timer? _recordingTimer;
  int recordingSeconds = 0;
  
  // Simulación de productos disponibles para prueba virtual
  List<Map<String, dynamic>> virtualProducts = [
    {
      'id': '1',
      'name': 'Vestido Floral',
      'image': 'https://via.placeholder.com/150x200',
      'category': 'Vestidos',
      'arModel': 'dress_floral.glb',
      'colors': ['#FF6B9D', '#4ECDC4', '#45B7D1'],
    },
    {
      'id': '2',
      'name': 'Blusa Elegante',
      'image': 'https://via.placeholder.com/150x200',
      'category': 'Blusas',
      'arModel': 'blouse_elegant.glb',
      'colors': ['#FFFFFF', '#000000', '#EC4899'],
    },
    {
      'id': '3',
      'name': 'Chaqueta Denim',
      'image': 'https://via.placeholder.com/150x200',
      'category': 'Chaquetas',
      'arModel': 'jacket_denim.glb',
      'colors': ['#1E40AF', '#374151', '#6B7280'],
    },
    {
      'id': '4',
      'name': 'Falda Plisada',
      'image': 'https://via.placeholder.com/150x200',
      'category': 'Faldas',
      'arModel': 'skirt_pleated.glb',
      'colors': ['#EF4444', '#10B981', '#F59E0B'],
    },
  ];

  List<String> availableFilters = [
    'none',
    'vintage',
    'bright',
    'soft',
    'dramatic',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCamera();
    
    // Ocultar instrucciones después de 5 segundos
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showInstructions = false;
        });
      }
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startCamera() async {
    setState(() {
      isLoading = true;
    });
    
    // Simular inicialización de cámara
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        isCameraActive = true;
        isLoading = false;
      });
    }
  }

  void _switchCamera() {
    setState(() {
      selectedCamera = selectedCamera == 'front' ? 'rear' : 'front';
      isLoading = true;
    });
    
    // Simular cambio de cámara
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _selectProduct(Map<String, dynamic> product) {
    setState(() {
      selectedProduct = product['id'];
      isLoading = true;
    });
    
    // Simular carga del modelo 3D
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      recordingSeconds = 0;
    });
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordingSeconds++;
      });
    });
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
    });
    _recordingTimer?.cancel();
    
    // Mostrar opciones para compartir
    _showShareOptions();
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Grabación completada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  icon: Icons.video_library,
                  label: 'Guardar',
                  onTap: () => Navigator.pop(context),
                ),
                _buildShareButton(
                  icon: Icons.share,
                  label: 'Compartir',
                  onTap: () => Navigator.pop(context),
                ),
                _buildShareButton(
                  icon: Icons.shopping_cart,
                  label: 'Comprar',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/ropa_calzado/checkout');
                  },
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
            padding: const EdgeInsets.all(16),
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros de Cámara',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableFilters.length,
                itemBuilder: (context, index) {
                  final filter = availableFilters[index];
                  final isSelected = currentFilter == filter;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFEC4899) 
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected 
                            ? Border.all(color: const Color(0xFFEC4899), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_vintage,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo usar la Prueba Virtual'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Permite el acceso a la cámara'),
            SizedBox(height: 8),
            Text('2. Selecciona una prenda del panel lateral'),
            SizedBox(height: 8),
            Text('3. Mantente en el centro de la pantalla'),
            SizedBox(height: 8),
            Text('4. Usa los controles para grabar o tomar fotos'),
            SizedBox(height: 8),
            Text('5. Comparte tu look en redes sociales'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Prueba Virtual AR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              selectedCamera == 'front' ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
            ),
            onPressed: _switchCamera,
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Área de la cámara con AR
          Positioned.fill(
            child: Container(
              color: Colors.grey[900],
              child: isCameraActive
                  ? _buildARCameraView()
                  : _buildCameraPlaceholder(),
            ),
          ),
          
          // Overlay de escaneo corporal
          if (isCameraActive && selectedProduct.isNotEmpty)
            _buildBodyScanOverlay(),
          
          // Panel de productos virtuales
          Positioned(
            right: 16,
            top: 100,
            bottom: 200,
            child: _buildProductPanel(),
          ),
          
          // Controles de zoom
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: _buildZoomControls(),
          ),
          
          // Instrucciones flotantes
          if (showInstructions)
            _buildInstructions(),
          
          // Controles inferiores mejorados
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildAdvancedBottomControls(),
          ),
          
          // Indicador de grabación
          if (isRecording)
            _buildRecordingIndicator(),
          
          // Indicador de carga
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFEC4899),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Cargando modelo 3D...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildARCameraView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Simulación de vista de cámara
          Center(
            child: Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Colócate aquí',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Overlay de prenda virtual si hay una seleccionada
          if (selectedProduct.isNotEmpty)
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 180,
                      height: 240,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEC4899),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Prenda Virtual\nActiva',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Iniciando cámara...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyScanOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          top: 100 + (_scanAnimation.value * 400),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFEC4899),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductPanel() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Prendas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: virtualProducts.length,
              itemBuilder: (context, index) {
                final product = virtualProducts[index];
                final isSelected = selectedProduct == product['id'];
                
                return GestureDetector(
                  onTap: () => _selectProduct(product),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFEC4899) 
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.checkroom,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
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
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                zoomLevel = (zoomLevel + 0.2).clamp(1.0, 3.0);
              });
            },
            icon: const Icon(Icons.zoom_in, color: Colors.white),
          ),
          Text(
            '${zoomLevel.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                zoomLevel = (zoomLevel - 0.2).clamp(1.0, 3.0);
              });
            },
            icon: const Icon(Icons.zoom_out, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Instrucciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showInstructions = false;
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• Selecciona una prenda del panel lateral\n'
              '• Mantente centrado en la pantalla\n'
              '• Usa los controles para grabar o fotografiar',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón de foto
          GestureDetector(
            onTap: () {
              // Simular captura de foto
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto capturada'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          // Botón de grabación
          GestureDetector(
            onTap: isRecording ? _stopRecording : _startRecording,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isRecording 
                    ? Colors.red 
                    : const Color(0xFFEC4899),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.videocam,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          // Botón de comprar
          GestureDetector(
            onTap: selectedProduct.isNotEmpty 
                ? () => context.push('/ropa_calzado/checkout')
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedProduct.isNotEmpty 
                    ? const Color(0xFFEC4899)
                    : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Positioned(
      top: 100,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${recordingSeconds ~/ 60}:${(recordingSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}