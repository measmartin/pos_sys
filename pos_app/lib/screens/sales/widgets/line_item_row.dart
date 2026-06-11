import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sales_model.dart';

class LineItemRow extends StatelessWidget {
  final SalesItemDetailsDto item;
  final NumberFormat c;

  const LineItemRow({
    required this.item,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final qtyText = item.quantity % 1 == 0
        ? item.quantity.toStringAsFixed(0)
        : item.quantity.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${item.lineNumber}',
                style: GoogleFonts.publicSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown product',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '$qtyText x ${c.format(item.unitPrice)}  •  ${item.unitName ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            c.format(item.lineTotal),
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
