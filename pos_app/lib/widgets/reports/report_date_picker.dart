import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';
import 'package:intl/intl.dart';

class ReportDatePicker extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DatePreset preset;
  final void Function(DateTime start, DateTime end, DatePreset preset) onDateChange;

  const ReportDatePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.preset,
    required this.onDateChange,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: GoogleFonts.publicSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: DatePreset.values.map((p) {
              final isSelected = p == preset;
              return InkWell(
                onTap: () {
                  final range = ReportProvider.getDateRangeFromPreset(p);
                  onDateChange(range.start, range.end, p);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                    ),
                  ),
                  child: Text(
                    _presetLabel(p),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dateField(context, 'From', startDate),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(context, 'To', endDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateField(BuildContext context, String label, DateTime date) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) {
          onDateChange(
            label == 'From' ? picked : startDate,
            label == 'To' ? picked : endDate,
            DatePreset.custom,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _presetLabel(DatePreset preset) {
    switch (preset) {
      case DatePreset.today: return 'Today';
      case DatePreset.yesterday: return 'Yesterday';
      case DatePreset.thisWeek: return 'This Week';
      case DatePreset.lastWeek: return 'Last Week';
      case DatePreset.thisMonth: return 'This Month';
      case DatePreset.lastMonth: return 'Last Month';
      case DatePreset.last30Days: return '30 Days';
      case DatePreset.thisYear: return 'This Year';
      case DatePreset.custom: return 'Custom';
    }
  }
}
