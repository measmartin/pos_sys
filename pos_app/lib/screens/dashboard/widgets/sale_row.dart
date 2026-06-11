import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/currency_utils.dart';

class SaleRow extends StatelessWidget {
  final dynamic sale;
  const SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final currencyCode = sale.currencyCode as String?;
    final currencySymbol = sale.currencySymbol as String? ?? sale.currencyCode as String? ?? r'$';
    final status = sale.paymentStatus as String;
    final statusColor = status == 'PAID'
        ? AppColors.primary
        : status == 'PARTIAL'
        ? AppColors.tertiary
        : AppColors.error;

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha:0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                sale.saleNumber,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM d, HH:mm').format(sale.saleDate),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                sale.customerName ?? 'Walk-in',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.publicSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formatAmount((sale.totalAmount as num).toDouble(), currencyCode, currencySymbol),
                textAlign: TextAlign.right,
                style: GoogleFonts.notoSerif(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
