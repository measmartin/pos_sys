import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<dynamic> data;
  final String currencySymbol;
  const WeeklyBarChart({
    required this.data,
    this.currencySymbol = r'$',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 180);
    final maxVal = data
        .map((d) => (d['amount'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[groupIndex];
                return BarTooltipItem(
                  '$currencySymbol${(d['amount'] as num).toStringAsFixed(0)}',
                  GoogleFonts.inter(
                    color: AppColors.inverseOnSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  final isToday = idx == data.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx]['day'] as String,
                      style: GoogleFonts.publicSans(
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.outlineVariant.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            final isToday = e.key == data.length - 1;
            final val = (e.value['amount'] as num).toDouble();
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: val,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                  color: isToday
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
