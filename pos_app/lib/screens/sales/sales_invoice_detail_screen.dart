import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/sales_model.dart';
import 'widgets/line_item_row.dart';

class SalesInvoiceDetailScreen extends StatelessWidget {
  final SalesDetailsDto sale;

  const SalesInvoiceDetailScreen({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final c = NumberFormat.currency(
      symbol: sale.currencySymbol ?? sale.currencyCode ?? r'$',
    );
    final statusColor = sale.paymentStatus == 'PAID'
        ? AppColors.primary
        : sale.paymentStatus == 'PARTIAL'
            ? AppColors.tertiary
            : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVOICE DETAILS',
              style: GoogleFonts.publicSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.secondary,
              ),
            ),
            Text(
              sale.saleNumber,
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d yyyy  HH:mm').format(sale.saleDate),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sale.customerName ?? 'Walk-in Patron',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sale.paymentStatus,
                    style: GoogleFonts.publicSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ITEMS',
            style: GoogleFonts.publicSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: sale.items
                  .map((item) => LineItemRow(item: item, c: c))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _totRow('Subtotal', c.format(sale.subtotal)),
                if (sale.totalDiscount > 0)
                  _totRow(
                    'Discount',
                    '-${c.format(sale.totalDiscount)}',
                    color: AppColors.error,
                  ),
                const Divider(height: 18),
                _totRow('Total', c.format(sale.totalAmount), bold: true, large: true),
                _totRow('Paid', c.format(sale.amountPaid)),
                if (sale.changeAmount > 0)
                  _totRow('Change', c.format(sale.changeAmount), color: AppColors.primary),
              ],
            ),
          ),
          if (sale.notes != null && sale.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'NOTES',
              style: GoogleFonts.publicSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sale.notes!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _totRow(String label, String value,
      {Color? color, bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: large ? 16 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSerif(
              fontSize: large ? 18 : 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
