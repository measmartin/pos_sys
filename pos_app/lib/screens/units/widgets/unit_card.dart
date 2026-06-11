import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unit_model.dart';

class UnitCard extends StatelessWidget {
  final UnitDetailsDto unit;
  final VoidCallback onTap;
  const UnitCard({required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.straighten,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            unit.unitName,
                            style: GoogleFonts.notoSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              unit.unitCode,
                              style: GoogleFonts.publicSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (unit.description != null &&
                          unit.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            unit.description!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: unit.isActive
                        ? AppColors.primary.withValues(alpha:0.08)
                        : AppColors.error.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    unit.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: GoogleFonts.publicSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: unit.isActive
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.outline, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
