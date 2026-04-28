import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'sale_row.dart';

class RecentSalesTable extends StatelessWidget {
  final List sales;
  const RecentSalesTable({required this.sales});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: _colHeader('SALE #')),
                Expanded(flex: 2, child: _colHeader('DATE')),
                Expanded(flex: 3, child: _colHeader('CUSTOMER')),
                Expanded(flex: 1, child: _colHeader('STATUS')),
                Expanded(flex: 2, child: _colHeader('TOTAL', right: true)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...sales.map((s) => SaleRow(sale: s)),
        ],
      ),
    );
  }

  Widget _colHeader(String t, {bool right = false}) => Text(
    t,
    textAlign: right ? TextAlign.right : TextAlign.left,
    style: GoogleFonts.publicSans(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: AppColors.secondary,
    ),
  );
}
