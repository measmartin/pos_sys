import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text('No sales found',
                style: GoogleFonts.notoSerif(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Complete a sale to see it here.',
                style: GoogleFonts.inter(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}
