import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
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
  
  Future<void> _scanQRCode() async {
    if (_isScanning) return;
    
    setState(() => _isScanning = true);
    
    try {
      final result = await BarcodeScanner.scan();
      
      if (result.type == ResultType.Barcode && result.rawContent != null) {
        final qrData = QRService.parseProductQR(result.rawContent!);
        
        if (qrData != null) {
          widget.onQRScanned({
            'type': 'product',
            'productId': qrData,
            'raw': result.rawContent,
          });
          
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Intentar parsear como venta o entrada
          final ventaData = QRService.parseVentaQR(result.rawContent!);
          final entradaData = QRService.parseEntradaQR(result.rawContent!);
          
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
            if (mounted) {
              _showError('QR no reconocido: ${result.rawContent}');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al escanear: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
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
                        const Text(
                          'Posiciona el código QR dentro del marco',
                          style: TextStyle(
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
                              decoration: BoxDecoration(
                                border: Border(
                                  top: const BorderSide(color: Color(0xFF2563EB), width: 4),
                                  left: const BorderSide(color: Color(0xFF2563EB), width: 4),
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
                              decoration: BoxDecoration(
                                border: Border(
                                  top: const BorderSide(color: Color(0xFF2563EB), width: 4),
                                  right: const BorderSide(color: Color(0xFF2563EB), width: 4),
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
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: const BorderSide(color: Color(0xFF2563EB), width: 4),
                                  left: const BorderSide(color: Color(0xFF2563EB), width: 4),
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
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: const BorderSide(color: Color(0xFF2563EB), width: 4),
                                  right: const BorderSide(color: Color(0xFF2563EB), width: 4),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _scanQRCode,
                      icon: const Icon(Icons.qr_code_scanner, size: 28),
                      label: Text(
                        _isScanning ? 'Escaneando...' : 'Escanear Código QR',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

