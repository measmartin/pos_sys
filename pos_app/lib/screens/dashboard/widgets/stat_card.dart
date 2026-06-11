import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  final double valueFontSize;
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AppColors.primary,
    this.valueFontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.secondary,
                ),
              ),
              Icon(icon, color: accent.withValues(alpha:0.35), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.notoSerif(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
