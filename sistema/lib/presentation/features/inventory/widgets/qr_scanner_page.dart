import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/qr_service.dart';

/// Página de escáner QR para productos
class QRScannerPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onQRScanned;
  
  const QRScannerPage({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanning = false;
  bool _permissionGranted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // En web, mostrar directamente el diálogo de entrada manual
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showManualInputDialog();
      });
    } else {
      // Solicitar permisos y abrir escáner automáticamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestPermissionAndScan();
      });
    }
  }

  Future<void> _requestPermissionAndScan() async {
    // En web, no solicitar permisos
    if (kIsWeb) {
      _showManualInputDialog();
      return;
    }

    try {
      // Solicitar permiso de cámara
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        setState(() {
          _permissionGranted = true;
          _errorMessage = null;
        });
        // Abrir escáner automáticamente
        _scanQRCode();
      } else if (status.isDenied) {
        setState(() {
          _errorMessage = 'Permiso de cámara denegado. Por favor, habilita el permiso en configuración.';
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _errorMessage = 'Permiso de cámara permanentemente denegado. Ve a configuración para habilitarlo.';
        });
      }
    } catch (e) {
      // Si hay error (como en web), mostrar entrada manual
      if (mounted) {
        _showManualInputDialog();
      }
    }
  }
  
  Future<void> _scanQRCode() async {
    // En web, mostrar diálogo para ingresar código manualmente
    if (kIsWeb) {
      _showManualInputDialog();
      return;
    }

    if (_isScanning || !_permissionGranted) {
      if (!_permissionGranted) {
        await _requestPermissionAndScan();
      }
      return;
    }
    
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });
    
    try {
      final result = await BarcodeScanner.scan();
      
      if (result.type == ResultType.Barcode && result.rawContent != null) {
        _processQRResult(result.rawContent!);
      } else {
        setState(() {
          _errorMessage = 'No se detectó ningún código QR válido';
        });
      }
    } catch (e) {
      if (mounted) {
        // Si el usuario canceló, solo cerrar sin mostrar error
        if (e.toString().contains('User canceled') || 
            e.toString().contains('cancel') ||
            e.toString().contains('Unsupported operation')) {
          // En web o si hay error de plataforma, mostrar diálogo manual
          if (kIsWeb || e.toString().contains('Unsupported operation')) {
            _showManualInputDialog();
          } else {
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _errorMessage = 'Error al escanear: ${e.toString().replaceAll('Exception: ', '')}';
          });
          // Si es error de plataforma, ofrecer entrada manual
          if (e.toString().contains('Unsupported operation')) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _showManualInputDialog();
              }
            });
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _processQRResult(String rawContent) {
    final qrData = QRService.parseProductQR(rawContent);
    
    if (qrData != null) {
      widget.onQRScanned({
        'type': 'product',
        'productId': qrData,
        'raw': rawContent,
      });
      
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      // Intentar parsear como venta o entrada
      final ventaData = QRService.parseVentaQR(rawContent);
      final entradaData = QRService.parseEntradaQR(rawContent);
      
      if (ventaData != null) {
        widget.onQRScanned(ventaData);
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (entradaData != null) {
        widget.onQRScanned(entradaData);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Si no se reconoce, usar el código directamente como ID de producto
        widget.onQRScanned({
          'type': 'product',
          'productId': rawContent,
          'raw': rawContent,
        });
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            const Expanded(child: Text('Ingresar Código Manualmente')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'El escáner de cámara no está disponible en esta plataforma. Por favor, ingresa el código manualmente:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Código QR / Código de Barras',
                hintText: 'Ingresa el código aquí',
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _processQRResult(value);
                  Navigator.pop(context);
                }
              },
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
              if (controller.text.isNotEmpty) {
                _processQRResult(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Procesar'),
          ),
        ],
      ),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Placeholder para la cámara
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isScanning)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                          )
                        else
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2563EB),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 150,
                              color: const Color(0xFF2563EB).withOpacity(0.3),
                            ),
                          ),
                        const SizedBox(height: 32),
                        Text(
                          _isScanning 
                            ? 'Escaneando...'
                            : _errorMessage ?? 'Posiciona el código QR dentro del marco',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Overlay de esquinas
                  if (!_isScanning)
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Esquina superior izquierda
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF2563EB), width: 4),
                                    left: BorderSide(color: Color(0xFF2563EB), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            // Esquina superior derecha
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF2563EB), width: 4),
                                    right: BorderSide(color: Color(0xFF2563EB), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            // Esquina inferior izquierda
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF2563EB), width: 4),
                                    left: BorderSide(color: Color(0xFF2563EB), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            // Esquina inferior derecha
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF2563EB), width: 4),
                                    right: BorderSide(color: Color(0xFF2563EB), width: 4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Controles
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : () {
                        if (kIsWeb) {
                          _showManualInputDialog();
                        } else {
                          _scanQRCode();
                        }
                      },
                      icon: Icon(
                        _isScanning 
                          ? Icons.hourglass_empty 
                          : (kIsWeb ? Icons.keyboard : Icons.qr_code_scanner), 
                        size: 28,
                      ),
                      label: Text(
                        _isScanning 
                          ? 'Escaneando...' 
                          : (kIsWeb ? 'Ingresar Código Manualmente' : 'Escanear Código QR'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  if (!_permissionGranted) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: const Text(
                        'Abrir Configuración',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                  if (_permissionGranted) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Usa el botón para activar la cámara y escanear',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

