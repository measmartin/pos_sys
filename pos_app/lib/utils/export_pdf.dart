import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_app/data/models/report_model.dart';
import 'package:intl/intl.dart';

class ExportPdf {
  static Future<void> exportSales(
    List<SalesExportDto> sales,
    SalesSummaryDto? summary,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Header(level: 0, text: 'Sales Report'),
        footer: (context) => pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          if (summary != null) {
            widgets.add(pw.SizedBox(height: 10));
            widgets.add(pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _statBox('Revenue', '\$${summary.totalRevenue.toStringAsFixed(2)}'),
                _statBox('Transactions', '${summary.transactionCount}'),
                _statBox('Avg Order', '\$${summary.avgOrderValue.toStringAsFixed(2)}'),
              ],
            ));
            widgets.add(pw.SizedBox(height: 20));
          }

          widgets.add(pw.TableHelper.fromTextArray(
            headers: ['Sale #', 'Date', 'Customer', 'Total', 'Status'],
            data: sales.map((s) => [
              s.saleNumber,
              dateFormat.format(s.saleDate),
              s.customerName ?? 'Walk-in',
              s.totalAmount.toStringAsFixed(2),
              s.paymentStatus,
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellHeight: 20,
            cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.center, 2: pw.Alignment.centerLeft, 3: pw.Alignment.centerRight, 4: pw.Alignment.center},
          ));

          return widgets;
        },
      ),
    );

    await _saveAndShare(pdf, 'sales-report');
  }

  static Future<void> exportProducts(List<TopProductDto> products) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Header(level: 0, text: 'Top Products Report'),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Product', 'Category', 'Qty', 'Revenue', 'Sales'],
            data: products.asMap().entries.map((e) => [
              '${e.key + 1}',
              e.value.productName,
              e.value.categoryName ?? '-',
              e.value.totalQuantity.toStringAsFixed(0),
              e.value.totalRevenue.toStringAsFixed(2),
              '${e.value.saleCount}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellHeight: 20,
          ),
        ],
      ),
    );

    await _saveAndShare(pdf, 'products-report');
  }

  static Future<void> exportCustomers(List<TopCustomerDto> customers) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Header(level: 0, text: 'Top Customers Report'),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Customer', 'Phone', 'Total Spent', 'Visits'],
            data: customers.asMap().entries.map((e) => [
              '${e.key + 1}',
              e.value.customerName,
              e.value.phoneNumber ?? '-',
              e.value.totalSpent.toStringAsFixed(2),
              '${e.value.visitCount}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellHeight: 20,
          ),
        ],
      ),
    );

    await _saveAndShare(pdf, 'customers-report');
  }

  static Future<void> exportPayments(List<PaymentBreakdownDto> payments) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Header(level: 0, text: 'Payment Breakdown'),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['Status', 'Count', 'Total Amount', 'Percentage'],
            data: payments.map((p) => [
              p.paymentStatus,
              '${p.count}',
              p.totalAmount.toStringAsFixed(2),
              '${p.percentage}%',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellHeight: 20,
          ),
        ],
      ),
    );

    await _saveAndShare(pdf, 'payments-report');
  }

  static pw.Container _statBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static Future<void> _saveAndShare(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename-${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(file.path)], text: filename.replaceAll('-', ' ').toUpperCase());
    } finally {
      // Clean up temp file after sharing
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }
}
