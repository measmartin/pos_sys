import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';

class ReportTabBar extends StatelessWidget {
  final ReportTab activeTab;
  final void Function(ReportTab) onTabChange;

  const ReportTabBar({super.key, required this.activeTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ReportTab.values.map((tab) {
          final isActive = tab == activeTab;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChange(tab),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _tabLabel(tab),
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tabLabel(ReportTab tab) {
    switch (tab) {
      case ReportTab.sales: return 'Sales';
      case ReportTab.products: return 'Products';
      case ReportTab.customers: return 'Customers';
      case ReportTab.payments: return 'Payments';
    }
  }
}
