import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value, trend;
  final IconData icon;
  final bool? trendUp;
  final Color accent;
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.trend,
    required this.trendUp,
    this.accent = AppColors.primary,
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
            color: Colors.black.withOpacity(0.04),
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
              Icon(icon, color: accent.withOpacity(0.35), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.notoSerif(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (trendUp != null)
                Icon(
                  trendUp! ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: trendUp! ? AppColors.primary : AppColors.error,
                ),
              if (trendUp != null) const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: trendUp == true
                      ? AppColors.primary
                      : trendUp == false
                      ? AppColors.error
                      : AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
