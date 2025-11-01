import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

/// Servicio para generar y escanear códigos QR
class QRService {
  /// Genera un código QR para un producto
  static Widget generateQRCode({
    required String data,
    required double size,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return QrImageView(
      data: data,
      size: size,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      foregroundColor: foregroundColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(8),
      embeddedImage: null,
      embeddedImageStyle: null,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );
  }

  /// Genera un código QR con logo del producto
  static Widget generateQRCodeWithLogo({
    required String data,
    required double size,
    ImageProvider? logoImage,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return QrImageView(
      data: data,
      size: size,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      foregroundColor: foregroundColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(8),
      embeddedImage: logoImage,
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(60, 60),
        color: Colors.white,
      ),
    );
  }

  /// Genera un código QR para datos de venta
  static String generateVentaQRData({
    required String productoId,
    required String productoNombre,
    required double precio,
    required int cantidad,
  }) {
    return 'VENTA|$productoId|$productoNombre|$precio|$cantidad|${DateTime.now().toIso8601String()}';
  }

  /// Genera un código QR para entrada de stock
  static String generateEntradaQRData({
    required String productoId,
    required int cantidad,
    required String proveedor,
  }) {
    return 'ENTRADA|$productoId|$cantidad|$proveedor|${DateTime.now().toIso8601String()}';
  }

  /// Parse QR data de venta
  static Map<String, dynamic>? parseVentaQR(String data) {
    try {
      final parts = data.split('|');
      if (parts.length >= 5 && parts[0] == 'VENTA') {
        return {
          'tipo': 'venta',
          'productoId': parts[1],
          'productoNombre': parts[2],
          'precio': double.tryParse(parts[3]) ?? 0.0,
          'cantidad': int.tryParse(parts[4]) ?? 1,
          'fecha': parts.length > 5 ? parts[5] : null,
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Parse QR data de entrada
  static Map<String, dynamic>? parseEntradaQR(String data) {
    try {
      final parts = data.split('|');
      if (parts.length >= 4 && parts[0] == 'ENTRADA') {
        return {
          'tipo': 'entrada',
          'productoId': parts[1],
          'cantidad': int.tryParse(parts[2]) ?? 1,
          'proveedor': parts[3],
          'fecha': parts.length > 4 ? parts[4] : null,
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Genera imagen de QR como bytes
  static Future<Uint8List> generateQRCodeBytes({
    required String data,
    required double size,
    Color? foregroundColor,
    Color? backgroundColor,
  }) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final painter = QrPainter(
          data: data,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          color: foregroundColor ?? Colors.black,
          emptyColor: backgroundColor ?? Colors.white,
          embeddedImageStyle: null,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        );

        painter.paint(canvas, Size(size, size));
        final picture = recorder.endRecording();
        final image = await picture.toImage(size.toInt(), size.toInt());
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        return byteData?.buffer.asUint8List() ?? Uint8List(0);
      }
    } catch (e) {
      return Uint8List(0);
    }

    return Uint8List(0);
  }

  /// Valida si un string es un QR válido
  static bool isValidQRFormat(String data) {
    return data.contains('|');
  }

  /// Genera QR simple para ID de producto
  static String generateProductQRData(String productId) {
    return 'PRODUCTO|$productId';
  }

  /// Parse QR de producto simple
  static String? parseProductQR(String data) {
    try {
      final parts = data.split('|');
      if (parts.length >= 2 && parts[0] == 'PRODUCTO') {
        return parts[1];
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

