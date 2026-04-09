import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class EmptySales extends StatelessWidget {
  const EmptySales();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No recent sales',
              style: GoogleFonts.inter(color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
