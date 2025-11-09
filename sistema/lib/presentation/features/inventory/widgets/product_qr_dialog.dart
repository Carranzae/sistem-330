import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../../../core/services/qr_service.dart';
import '../../../../core/services/pdf_service.dart';

/// Diálogo para mostrar código QR del producto
class ProductQRDialog extends StatelessWidget {
  final String productId;
  final String productName;
  final String productCode;
  final double price;

  const ProductQRDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = QRService.generateProductQRData(productId);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Código QR del Producto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // QR Code
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              ),
              child: QRService.generateQRCode(
                data: qrData,
                size: 200,
                foregroundColor: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info del producto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nombre', productName),
                  const Divider(),
                  _buildInfoRow('Código', productCode),
                  const Divider(),
                  _buildInfoRow('Precio', 'S/ $price'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        // Copiar código QR al portapapeles
                        await Clipboard.setData(ClipboardData(text: qrData));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Código QR copiado al portapapeles'),
                                ],
                              ),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al copiar: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // Generar imagen del QR como bytes
                        final qrBytes = await QRService.generateQRCodeBytes(
                          data: qrData,
                          size: 300,
                        );
                        
                        if (context.mounted) {
                          // Usar el servicio de impresión
                          await Printing.layoutPdf(
                            onLayout: (format) async {
                              // Crear un PDF simple con el QR
                              final pdf = await PDFService.generateQRPDF(
                                qrBytes: qrBytes,
                                productName: productName,
                                productCode: productCode,
                                price: price,
                              );
                              return pdf;
                            },
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al imprimir: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

