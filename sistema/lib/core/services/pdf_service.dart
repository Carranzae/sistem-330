import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Servicio para generar PDFs de boletas y facturas
class PDFService {
  /// Genera un PDF de Boleta de Venta Electrónica
  static Future<Uint8List> generateBoletaPDF({
    required String nombreComercial,
    required String ruc,
    required String direccion,
    required String serie,
    required int correlativo,
    required String fechaEmision,
    required String? clienteDocumento,
    required String? clienteNombre,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double igv,
    required double total,
    required String moneda,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header con logo y datos del negocio
              _buildHeader(
                nombreComercial: nombreComercial,
                ruc: ruc,
                direccion: direccion,
              ),
              
              pw.SizedBox(height: 30),
              
              // Título BOLETA
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'BOLETA DE VENTA ELECTRÓNICA',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Información del comprobante
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'N° COMPROBANTE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '$serie-$correlativo',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FECHA DE EMISIÓN',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        fechaEmision,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Datos del cliente
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DATOS DEL CLIENTE',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Documento: ',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          clienteDocumento ?? 'N/A',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Nombre: ',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          clienteNombre ?? 'CLIENTE GENERAL',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Tabla de items
              _buildItemsTable(items, moneda),
              
              pw.Spacer(),
              
              // Totales
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${moneda == 'PEN' ? 'S/' : moneda} $total',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Pie de página legal
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF de Factura Electrónica (similar a boleta con más detalles)
  static Future<Uint8List> generateFacturaPDF({
    required String nombreComercial,
    required String ruc,
    required String direccion,
    required String serie,
    required int correlativo,
    required String fechaEmision,
    required String fechaVencimiento,
    required String clienteRuc,
    required String clienteNombre,
    required String clienteDireccion,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double igv,
    required double total,
    required String moneda,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header con logo y datos del negocio
              _buildHeader(
                nombreComercial: nombreComercial,
                ruc: ruc,
                direccion: direccion,
              ),
              
              pw.SizedBox(height: 30),
              
              // Título FACTURA
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'FACTURA ELECTRÓNICA',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Información del comprobante
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'N° COMPROBANTE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '$serie-$correlativo',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FECHA DE EMISIÓN',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        fechaEmision,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Datos del cliente (más detallado para factura)
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DATOS DEL ADQUIRENTE',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Text(
                          'RUC: ',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          clienteRuc,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Razón Social: ',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          clienteNombre,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Dirección: ',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          clienteDireccion,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Tabla de items
              _buildItemsTable(items, moneda),
              
              pw.Spacer(),
              
              // Totales detallados
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:'),
                        pw.Text('${moneda == 'PEN' ? 'S/' : moneda} $subtotal'),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('IGV (18%):'),
                        pw.Text('${moneda == 'PEN' ? 'S/' : moneda} $igv'),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${moneda == 'PEN' ? 'S/' : moneda} $total',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Pie de página legal
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Build header con datos del negocio
  static pw.Widget _buildHeader({
    required String nombreComercial,
    required String ruc,
    required String direccion,
  }) {
    return pw.Row(
      children: [
        // Logo placeholder
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            color: PdfColors.blue700,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              nombreComercial.substring(0, 2).toUpperCase(),
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        // Datos del negocio
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                nombreComercial,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'RUC: $ruc',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                direccion,
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build tabla de items
  static pw.Widget _buildItemsTable(
    List<Map<String, dynamic>> items,
    String moneda,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Descripción',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Cant.',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'P. Unit.',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'IGV',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Total',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        // Items
        for (var item in items)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  item['nombre'] ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${item['cantidad'] ?? 0}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${moneda == 'PEN' ? 'S/' : moneda} ${item['precio'] ?? '0.00'}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${moneda == 'PEN' ? 'S/' : moneda} ${item['igv'] ?? '0.00'}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${moneda == 'PEN' ? 'S/' : moneda} ${item['total'] ?? '0.00'}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Build footer legal
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Representación impresa del comprobante de venta electrónico',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Autorizado mediante Resolución de SUNAT',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Preview e impresión del PDF
  static Future<void> previewAndPrint(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Compartir PDF
  static Future<void> sharePDF(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }

  /// Genera un PDF de Estado Financiero
  static Future<Uint8List> generateFinancialStatementPDF({
    required String nombreComercial,
    required String ruc,
    required String direccion,
    required String fechaDesde,
    required String fechaHasta,
    required double ingresosTotales,
    required double gastosTotales,
    required double gananciaNeta,
    required double margenGanancia,
    required List<Map<String, dynamic>> ingresos,
    required List<Map<String, dynamic>> gastos,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(
                nombreComercial: nombreComercial,
                ruc: ruc,
                direccion: direccion,
              ),
              
              pw.SizedBox(height: 30),
              
              // Título
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'ESTADO FINANCIERO',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Rango de fechas
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Período: $fechaDesde al $fechaHasta',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Resumen financiero
              _buildFinancialSummaryBox(
                ingresosTotales,
                gastosTotales,
                gananciaNeta,
                margenGanancia,
              ),
              
              pw.SizedBox(height: 30),
              
              // Ingresos
              _buildSectionTitle('INGRESOS'),
              pw.SizedBox(height: 10),
              _buildFinancialTable(ingresos, isIncome: true),
              
              pw.SizedBox(height: 20),
              
              // Gastos
              _buildSectionTitle('GASTOS'),
              pw.SizedBox(height: 10),
              _buildFinancialTable(gastos, isIncome: false),
              
              pw.Spacer(),
              
              // Pie de página
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Estado generado el ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildFinancialSummaryBox(
    double ingresos,
    double gastos,
    double ganancia,
    double margen,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400),
        children: [
          _buildSummaryRow('Ingresos Totales', ingresos, PdfColors.green700),
          _buildSummaryRow('Gastos Totales', gastos, PdfColors.red700),
          _buildSummaryRow('Ganancia Neta', ganancia, PdfColors.blue700),
          _buildSummaryRow('Margen de Ganancia', margen, PdfColors.purple700, isPercent: true),
        ],
      ),
    );
  }

  static pw.TableRow _buildSummaryRow(
    String label,
    double value,
    PdfColor color, {
    bool isPercent = false,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.white),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(
            isPercent ? '$value%' : 'S/ ${value.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
    );
  }

  static pw.Widget _buildFinancialTable(
    List<Map<String, dynamic>> items, {
    required bool isIncome,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isIncome ? PdfColors.green100 : PdfColors.red100,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Descripción',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Fecha',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Monto',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        // Items
        for (var item in items)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  item['descripcion'] ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  item['fecha'] ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'S/ ${(item['monto'] ?? 0.0).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: isIncome ? PdfColors.green700 : PdfColors.red700,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Genera un Certificado de Score y Ventas
  static Future<Uint8List> generateSalesScoreCertificatePDF({
    required String nombreComercial,
    required String ruc,
    required String direccion,
    required int score,
    required String scoreLevel,
    required String fechaInicio,
    required String fechaFin,
    required double totalVentas,
    required double totalIngresos,
    required double utilidadBruta,
    required double margenGanancia,
    required int totalClientes,
    required int totalProductos,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header con logo
              _buildHeader(
                nombreComercial: nombreComercial,
                ruc: ruc,
                direccion: direccion,
              ),
              
              pw.SizedBox(height: 30),
              
              // Título del certificado
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'CERTIFICADO DE SCORE Y VENTAS',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Score principal
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SCORE',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '$score',
                      style: pw.TextStyle(
                        fontSize: 72,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber700,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      scoreLevel.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 40),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 30),
              
              // Período
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'PERÍODO: $fechaInicio al $fechaFin',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Resumen de ventas
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200, width: 2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RESUMEN DE VENTAS',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    _buildCertificateRow('Total de Ventas', totalVentas, PdfColors.green700),
                    pw.SizedBox(height: 10),
                    _buildCertificateRow('Total de Ingresos', totalIngresos, PdfColors.green700),
                    pw.SizedBox(height: 10),
                    _buildCertificateRow('Utilidad Bruta', utilidadBruta, PdfColors.blue700),
                    pw.SizedBox(height: 10),
                    _buildCertificateRow('Margen de Ganancia', margenGanancia, PdfColors.purple700, isPercent: true),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Estadísticas adicionales
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200, width: 2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ESTADÍSTICAS ADICIONALES',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    _buildCertificateRow('Total de Clientes', totalClientes.toDouble(), PdfColors.blue700, isInteger: true),
                    pw.SizedBox(height: 10),
                    _buildCertificateRow('Total de Productos', totalProductos.toDouble(), PdfColors.blue700, isInteger: true),
                  ],
                ),
              ),
              
              pw.Spacer(),
              pw.SizedBox(height: 30),
              
              // Fecha de emisión
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Certificado emitido el ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCertificateRow(
    String label,
    double value,
    PdfColor color, {
    bool isPercent = false,
    bool isInteger = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey800,
          ),
        ),
        pw.Text(
          isPercent
              ? '$value%'
              : isInteger
                  ? '${value.toInt()} unidades'
                  : 'S/ ${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Genera un PDF de Movimientos de Inventario (Entradas o Salidas)
  static Future<Uint8List> generateInventoryMovementsPDF({
    required String nombreComercial,
    required String tipo, // 'Entradas' o 'Salidas'
    required List<Map<String, dynamic>> movimientos,
    required String fechaDesde,
    required String fechaHasta,
  }) async {
    // Usar tema con fuentes que soportan Unicode
    // El paquete pdf usa Helvetica por defecto que no tiene soporte Unicode completo
    // Usamos el tema por defecto que maneja mejor los caracteres especiales
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(
                nombreComercial: nombreComercial,
                ruc: '00000000000',
                direccion: 'Dirección del negocio',
              ),
              
              pw.SizedBox(height: 30),
              
              // Título
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: tipo == 'Entradas' ? PdfColors.green700 : PdfColors.red700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'REPORTE DE $tipo'.toUpperCase(),
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Rango de fechas
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Período: $fechaDesde al $fechaHasta',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Total: ${movimientos.length} registros',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Tabla de movimientos
              _buildMovementsTable(movimientos, tipo),
              
              pw.Spacer(),
              
              // Totales
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total de Registros:',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${movimientos.length}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Cantidad:',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${movimientos.fold<int>(0, (sum, m) => sum + ((m['cantidad'] ?? 0) as num).toInt())}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Pie de página
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Reporte generado el ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildMovementsTable(
    List<Map<String, dynamic>> movimientos,
    String tipo,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: tipo == 'Entradas' ? PdfColors.green100 : PdfColors.red100,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Código',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Producto',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Variedad',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Cantidad',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            if (tipo == 'Entradas')
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Stock Disp.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Fecha',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                tipo == 'Entradas' ? 'P. Compra' : 'Precio',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            if (tipo == 'Entradas')
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'P. Venta',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
          ],
        ),
        // Items
        for (var movimiento in movimientos)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  movimiento['codigo']?.toString() ?? movimiento['id']?.toString().substring(0, (movimiento['id']?.toString().length ?? 0) > 8 ? 8 : (movimiento['id']?.toString().length ?? 0)) ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  movimiento['producto'] ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  movimiento['variedad'] ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${movimiento['cantidad'] ?? 0} ${movimiento['unidad'] ?? 'un'}',
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (tipo == 'Entradas')
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '${movimiento['stock_disponible'] ?? movimiento['cantidad'] ?? 0} ${movimiento['unidad'] ?? 'un'}',
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  movimiento['fecha'] ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'S/ ${((movimiento[tipo == 'Entradas' ? 'precio_compra' : 'precio'] ?? movimiento['precio'] ?? 0.0) as num).toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              if (tipo == 'Entradas')
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'S/ ${((movimiento['precio_venta'] ?? 0.0) as num).toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// Genera un PDF con el código QR del producto para imprimir
  static Future<Uint8List> generateQRPDF({
    required Uint8List qrBytes,
    required String productName,
    required String productCode,
    required double price,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Título
              pw.Text(
                'Código QR del Producto',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Imagen del QR
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(qrBytes),
                  width: 300,
                  height: 300,
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Información del producto
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Nombre:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(productName, style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Código:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(productCode, style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Precio:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('S/ ${price.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Pie de página
              pw.Text(
                'Escanea el código QR para obtener información del producto',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF de Reporte de Ventas
  static Future<Uint8List> generateSalesReportPDF({
    required List<dynamic> sales,
    required Map<String, dynamic> stats,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORTE DE VENTAS',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Período: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Generado: ${dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Estadísticas
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Ventas', 'S/ ${(stats['totalSales'] ?? 0.0).toStringAsFixed(2)}'),
                    _buildStatItem('Transacciones', '${stats['totalTransactions'] ?? 0}'),
                    _buildStatItem('Promedio', 'S/ ${(stats['averageSale'] ?? 0.0).toStringAsFixed(2)}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Tabla de ventas
              pw.Text(
                'Detalle de Ventas',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Fecha', isHeader: true),
                      _buildTableCell('Cliente', isHeader: true),
                      _buildTableCell('Productos', isHeader: true),
                      _buildTableCell('Método', isHeader: true),
                      _buildTableCell('Total', isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...sales.map((sale) {
                    final fecha = sale['fecha'] is DateTime
                        ? DateFormat('dd/MM/yyyy HH:mm').format(sale['fecha'] as DateTime)
                        : sale['fecha']?.toString() ?? '';
                    final cliente = sale['cliente_nombre'] ?? 'Cliente General';
                    final productos = (sale['productos'] as List?)?.length ?? 0;
                    final metodo = sale['metodo_pago'] ?? 'efectivo';
                    final total = sale['total'] ?? 0.0;

                    return pw.TableRow(
                      children: [
                        _buildTableCell(fecha),
                        _buildTableCell(cliente),
                        _buildTableCell('$productos'),
                        _buildTableCell(metodo),
                        _buildTableCell('S/ ${(total as num).toStringAsFixed(2)}'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Genera un PDF de Reporte de Inventario
  static Future<Uint8List> generateInventoryReportPDF({
    required List<dynamic> products,
    required Map<String, dynamic> stats,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORTE DE INVENTARIO',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generado: ${dateFormat.format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Estadísticas
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Valor Total', 'S/ ${(stats['totalValue'] ?? 0.0).toStringAsFixed(2)}'),
                    _buildStatItem('Total Productos', '${stats['totalProducts'] ?? 0}'),
                    _buildStatItem('Stock Bajo', '${stats['lowStockCount'] ?? 0}'),
                    _buildStatItem('Sin Stock', '${stats['outOfStockCount'] ?? 0}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Tabla de productos
              pw.Text(
                'Detalle de Productos',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Código', isHeader: true),
                      _buildTableCell('Producto', isHeader: true),
                      _buildTableCell('Categoría', isHeader: true),
                      _buildTableCell('Stock', isHeader: true),
                      _buildTableCell('P. Compra', isHeader: true),
                      _buildTableCell('P. Venta', isHeader: true),
                      _buildTableCell('Valor Total', isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...products.map((product) {
                    final codigo = product['codigo'] ?? product['id'] ?? '';
                    final nombre = product['nombre'] ?? '';
                    final categoria = product['categoria'] ?? 'Otros';
                    final stock = product['stock'] ?? 0;
                    final precioCompra = product['precio_compra'] ?? product['precio'] ?? 0.0;
                    final precioVenta = product['precio_venta'] ?? product['precio'] ?? 0.0;
                    final valorTotal = (stock as num).toDouble() * (precioCompra as num).toDouble();

                    return pw.TableRow(
                      children: [
                        _buildTableCell(codigo),
                        _buildTableCell(nombre),
                        _buildTableCell(categoria),
                        _buildTableCell('$stock'),
                        _buildTableCell('S/ ${(precioCompra as num).toStringAsFixed(2)}'),
                        _buildTableCell('S/ ${(precioVenta as num).toStringAsFixed(2)}'),
                        _buildTableCell('S/ ${valorTotal.toStringAsFixed(2)}'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF de Reporte Financiero
  static Future<Uint8List> generateFinancialReportPDF({
    required Map<String, dynamic> stats,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORTE FINANCIERO',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Período: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildFinancialRow('Ingresos Totales', stats['totalRevenue'] ?? 0.0, PdfColors.green),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('Costos Totales', stats['totalCosts'] ?? 0.0, PdfColors.red),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('Ganancia Bruta', stats['grossProfit'] ?? 0.0, PdfColors.blue),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('Margen de Ganancia', '${(stats['profitMargin'] ?? 0.0).toStringAsFixed(2)}%', PdfColors.purple),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildFinancialRow(String label, dynamic value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value is num ? 'S/ ${value.toStringAsFixed(2)}' : value.toString(),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Genera un PDF de Reporte de Clientes
  static Future<Uint8List> generateClientsReportPDF({
    required List<dynamic> clients,
    required Map<String, dynamic> stats,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORTE DE CLIENTES',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generado: ${dateFormat.format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Clientes', '${stats['totalClients'] ?? 0}'),
                    _buildStatItem('Activos', '${stats['activeClients'] ?? 0}'),
                    _buildStatItem('Créditos', 'S/ ${(stats['totalCredits'] ?? 0.0).toStringAsFixed(2)}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Detalle de Clientes',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Nombre', isHeader: true),
                      _buildTableCell('Documento', isHeader: true),
                      _buildTableCell('Teléfono', isHeader: true),
                      _buildTableCell('Crédito', isHeader: true),
                      _buildTableCell('Estado', isHeader: true),
                    ],
                  ),
                  ...clients.map((client) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(client['nombre'] ?? ''),
                        _buildTableCell(client['documento'] ?? ''),
                        _buildTableCell(client['telefono'] ?? ''),
                        _buildTableCell('S/ ${((client['credito_pendiente'] ?? 0.0) as num).toStringAsFixed(2)}'),
                        _buildTableCell((client['activo'] ?? true) ? 'Activo' : 'Inactivo'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF de Productos por Vencer
  static Future<Uint8List> generateExpiringProductsReportPDF({
    required List<dynamic> products,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PRODUCTOS POR VENCER',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generado: ${dateFormat.format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Productos próximos a vencer (30 días)',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Producto', isHeader: true),
                      _buildTableCell('Categoría', isHeader: true),
                      _buildTableCell('Stock', isHeader: true),
                      _buildTableCell('Fecha Venc.', isHeader: true),
                      _buildTableCell('Días Rest.', isHeader: true),
                    ],
                  ),
                  ...products.map((product) {
                    final fechaVenc = product['fecha_vencimiento'] is DateTime 
                        ? product['fecha_vencimiento'] as DateTime
                        : DateTime.tryParse(product['fecha_vencimiento'].toString());
                    final diasRestantes = fechaVenc != null 
                        ? fechaVenc.difference(DateTime.now()).inDays
                        : 0;

                    return pw.TableRow(
                      children: [
                        _buildTableCell(product['nombre'] ?? ''),
                        _buildTableCell(product['categoria'] ?? 'Otros'),
                        _buildTableCell('${product['stock'] ?? 0}'),
                        _buildTableCell(fechaVenc != null ? dateFormat.format(fechaVenc) : ''),
                        _buildTableCell('$diasRestantes días'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF de Reporte de Caja
  static Future<Uint8List> generateCashReportPDF({
    required Map<String, dynamic> stats,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORTE DE CAJA',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Período: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildFinancialRow('Efectivo', stats['totalCash'] ?? 0.0, PdfColors.green),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('Tarjeta', stats['totalCard'] ?? 0.0, PdfColors.blue),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('Yape', stats['totalYape'] ?? 0.0, PdfColors.orange),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('Plin', stats['totalPlin'] ?? 0.0, PdfColors.purple),
                    pw.Divider(),
                    pw.SizedBox(height: 12),
                    _buildFinancialRow('TOTAL CAJA', stats['total'] ?? 0.0, PdfColors.blue700),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

