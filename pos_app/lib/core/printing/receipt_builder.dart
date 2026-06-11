import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../../data/models/sales_model.dart';
import '../../utils/currency_utils.dart';
import 'printer_settings.dart';

class ReceiptBuilder {
  static const int lineWidth80mm = 48;

  static Future<List<int>> build(SalesDetailsDto sale, StoreConfig store) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final lines = <int>[];

    lines.addAll(generator.reset());
    lines.addAll(generator.setStyles(const PosStyles(align: PosAlign.center)));

    lines.addAll(generator.text(store.name,
        styles: const PosStyles(bold: true, height: PosTextSize.size2)));

    if (store.address.isNotEmpty) {
      lines.addAll(generator.text(store.address,
          styles: const PosStyles(height: PosTextSize.size1)));
    }
    if (store.phone.isNotEmpty) {
      lines.addAll(generator.text(store.phone,
          styles: const PosStyles(height: PosTextSize.size1)));
    }

    lines.addAll(generator.hr(len: lineWidth80mm));
    lines.addAll(generator.setStyles(const PosStyles(align: PosAlign.left)));

    final dateStr =
        '${sale.saleDate.year}-${_two(sale.saleDate.month)}-${_two(sale.saleDate.day)} '
        '${_two(sale.saleDate.hour)}:${_two(sale.saleDate.minute)}';
    lines.addAll(generator.text(sale.saleNumber,
        styles: const PosStyles(bold: true)));
    lines.addAll(generator.text(dateStr,
        styles: const PosStyles(height: PosTextSize.size1)));
    if (sale.customerName != null && sale.customerName!.isNotEmpty) {
      lines.addAll(generator.text('Customer: ${sale.customerName}'));
    }
    lines.addAll(generator.hr(len: lineWidth80mm));

    lines.addAll(generator.row([
      PosColumn(text: 'Item', width: 20),
      PosColumn(
          text: 'Qty',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Price',
          width: 10,
          styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total',
          width: 12,
          styles: const PosStyles(align: PosAlign.right)),
    ]));
    lines.addAll(generator.hr(len: lineWidth80mm));

    final sym = sale.currencySymbol ?? sale.currencyCode ?? r'$';
    for (final item in sale.items) {
      final name = (item.productName ?? 'Item')
          .substring(0, (item.productName ?? 'Item').length.clamp(0, 20));
      lines.addAll(generator.row([
        PosColumn(text: name, width: 20),
        PosColumn(
            text: item.quantity ==
                    item.quantity.roundToDouble()
                ? item.quantity.toStringAsFixed(0)
                : item.quantity.toStringAsFixed(1),
            width: 6,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _fmt(item.unitPrice, sym, sale.currencyCode),
            width: 10,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _fmt(item.lineTotal, sym, sale.currencyCode),
            width: 12,
            styles: const PosStyles(align: PosAlign.right)),
      ]));
    }

    lines.addAll(generator.hr(len: lineWidth80mm));

    lines.addAll(generator.row([
      PosColumn(
          text: 'Subtotal',
          width: 24,
          styles: const PosStyles(bold: true)),
      PosColumn(
          text: _fmt(sale.subtotal, sym, sale.currencyCode),
          width: 24,
          styles: const PosStyles(align: PosAlign.right)),
    ]));
    if (sale.totalDiscount > 0) {
      final discLabel = sale.discountPercentage != null
          ? 'Discount (${sale.discountPercentage!.toStringAsFixed(0)}%)'
          : 'Discount';
      lines.addAll(generator.row([
        PosColumn(
            text: discLabel,
            width: 24,
            styles: const PosStyles(bold: true)),
        PosColumn(
            text: '-${_fmt(sale.totalDiscount, sym, sale.currencyCode)}',
            width: 24,
            styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
    lines.addAll(generator.hr(len: lineWidth80mm));
    lines.addAll(generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 24,
          styles: const PosStyles(
              bold: true, height: PosTextSize.size2)),
      PosColumn(
          text: _fmt(sale.totalAmount, sym, sale.currencyCode),
          width: 24,
          styles: const PosStyles(
              bold: true, height: PosTextSize.size2, align: PosAlign.right)),
    ]));
    lines.addAll(generator.hr(len: lineWidth80mm));

    lines.addAll(generator.row([
      PosColumn(text: 'Paid', width: 24),
      PosColumn(
          text: _fmt(sale.amountPaid, sym, sale.currencyCode),
          width: 24,
          styles: const PosStyles(align: PosAlign.right)),
    ]));
    if (sale.changeAmount > 0) {
      lines.addAll(generator.row([
        PosColumn(text: 'Change', width: 24),
        PosColumn(
            text: _fmt(sale.changeAmount, sym, sale.currencyCode),
            width: 24,
            styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
    lines.addAll(generator.row([
      PosColumn(text: 'Status', width: 24),
      PosColumn(
          text: sale.paymentStatus,
          width: 24,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]));

    lines.addAll(generator.hr(len: lineWidth80mm));
    lines.addAll(generator.setStyles(const PosStyles(align: PosAlign.center)));
    lines.addAll(generator.text('\nThank you!',
        styles: const PosStyles(bold: true)));
    lines.addAll(generator.feed(2));
    lines.addAll(generator.cut());
    return lines;
  }

  static Future<List<int>> buildTest(StoreConfig store) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final lines = <int>[];
    lines.addAll(generator.reset());
    lines.addAll(generator.setStyles(const PosStyles(align: PosAlign.center)));
    lines.addAll(generator.text(store.name,
        styles: const PosStyles(bold: true, height: PosTextSize.size2)));
    lines.addAll(generator.hr(len: lineWidth80mm));
    lines.addAll(generator.text('TEST PRINT',
        styles: const PosStyles(bold: true)));
    lines.addAll(generator.text(
        '${DateTime.now().year}-${_two(DateTime.now().month)}-${_two(DateTime.now().day)} '
        '${_two(DateTime.now().hour)}:${_two(DateTime.now().minute)}'));
    lines.addAll(generator.hr(len: lineWidth80mm));
    lines.addAll(generator.text('Printer connected\nsuccessfully!'));
    lines.addAll(generator.feed(2));
    lines.addAll(generator.cut());
    return lines;
  }

  static String _fmt(double value, String symbol, String? currencyCode) {
    final rounded = roundForCurrency(value, currencyCode);
    if (currencyCode?.toUpperCase() == 'KHR') {
      return '$symbol${rounded.toStringAsFixed(0)}';
    }
    if (rounded == rounded.roundToDouble()) {
      return '$symbol${rounded.toStringAsFixed(0)}';
    }
    return '$symbol${rounded.toStringAsFixed(2)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}