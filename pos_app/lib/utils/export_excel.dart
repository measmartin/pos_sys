import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:pos_app/data/models/report_model.dart';
import 'package:intl/intl.dart';

class ExportExcel {
  static Future<void> exportSales(List<SalesExportDto> sales) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Sales Report';

    final headers = [
      'Sale #', 'Date', 'Customer', 'Phone', 'Currency',
      'Subtotal', 'Discount', 'Total', 'Paid', 'Change',
      'Payment', 'Status', 'Notes'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    for (var row = 0; row < sales.length; row++) {
      final s = sales[row];
      final r = row + 2;
      sheet.getRangeByIndex(r, 1).setText(s.saleNumber);
      sheet.getRangeByIndex(r, 2).setText(dateFormat.format(s.saleDate));
      sheet.getRangeByIndex(r, 3).setText(s.customerName ?? 'Walk-in');
      sheet.getRangeByIndex(r, 4).setText(s.phoneNumber);
      sheet.getRangeByIndex(r, 5).setText(s.currencyCode);
      sheet.getRangeByIndex(r, 6).setNumber(s.subtotal);
      sheet.getRangeByIndex(r, 7).setNumber(s.totalDiscount);
      sheet.getRangeByIndex(r, 8).setNumber(s.totalAmount);
      sheet.getRangeByIndex(r, 9).setNumber(s.amountPaid);
      sheet.getRangeByIndex(r, 10).setNumber(s.changeAmount);
      sheet.getRangeByIndex(r, 11).setText(s.paymentStatus);
      sheet.getRangeByIndex(r, 12).setText(s.saleStatus);
      sheet.getRangeByIndex(r, 13).setText(s.notes ?? '');
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sales-report-${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Sales Report');
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  static Future<void> exportProducts(List<TopProductDto> products) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Top Products';

    final headers = ['#', 'Product', 'Category', 'Qty Sold', 'Revenue', 'Sales'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var row = 0; row < products.length; row++) {
      final p = products[row];
      final r = row + 2;
      sheet.getRangeByIndex(r, 1).setNumber((row + 1).toDouble());
      sheet.getRangeByIndex(r, 2).setText(p.productName);
      sheet.getRangeByIndex(r, 3).setText(p.categoryName ?? '-');
      sheet.getRangeByIndex(r, 4).setNumber(p.totalQuantity);
      sheet.getRangeByIndex(r, 5).setNumber(p.totalRevenue);
      sheet.getRangeByIndex(r, 6).setNumber(p.saleCount.toDouble());
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/products-report-${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Products Report');
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  static Future<void> exportCustomers(List<TopCustomerDto> customers) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Top Customers';

    final headers = ['#', 'Customer', 'Phone', 'Total Spent', 'Visits', 'Avg Order'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var row = 0; row < customers.length; row++) {
      final c = customers[row];
      final r = row + 2;
      sheet.getRangeByIndex(r, 1).setNumber((row + 1).toDouble());
      sheet.getRangeByIndex(r, 2).setText(c.customerName);
      sheet.getRangeByIndex(r, 3).setText(c.phoneNumber ?? '-');
      sheet.getRangeByIndex(r, 4).setNumber(c.totalSpent);
      sheet.getRangeByIndex(r, 5).setNumber(c.visitCount.toDouble());
      sheet.getRangeByIndex(r, 6).setNumber(c.avgOrderValue);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/customers-report-${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Customers Report');
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  static Future<void> exportPayments(List<PaymentBreakdownDto> payments) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Payment Breakdown';

    final headers = ['Status', 'Count', 'Total Amount', 'Percentage'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var row = 0; row < payments.length; row++) {
      final p = payments[row];
      final r = row + 2;
      sheet.getRangeByIndex(r, 1).setText(p.paymentStatus);
      sheet.getRangeByIndex(r, 2).setNumber(p.count.toDouble());
      sheet.getRangeByIndex(r, 3).setNumber(p.totalAmount);
      sheet.getRangeByIndex(r, 4).setNumber(p.percentage);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/payments-report-${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Payment Report');
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
