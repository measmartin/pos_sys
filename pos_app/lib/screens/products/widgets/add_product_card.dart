import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AddProductCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddProductCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha:0.6),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(4),
          color: AppColors.surfaceContainerLow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Curate New Item',
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expand your catalog',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
