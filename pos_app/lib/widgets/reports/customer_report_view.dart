import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';
import 'package:pos_app/data/models/report_model.dart';

class CustomerReportView extends StatelessWidget {
  const CustomerReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExportButtons(context, report),
        const SizedBox(height: 16),
        _buildCustomersChart(report.topCustomers),
        const SizedBox(height: 20),
        _buildCustomersTable(report.topCustomers),
      ],
    );
  }

  Widget _buildExportButtons(BuildContext context, ReportProvider report) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: report.exporting ? null : () => report.exportToExcel(),
            icon: report.exporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.table_chart, size: 18),
            label: Text(report.exporting ? 'Exporting...' : 'Excel'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: report.exporting ? null : () => report.exportToPdf(),
            icon: report.exporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf, size: 18),
            label: Text(report.exporting ? 'Exporting...' : 'PDF'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.onPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomersChart(List<TopCustomerDto> customers) {
    if (customers.isEmpty) return _emptyState('No customer data');

    final top8 = customers.take(8).toList();
    final maxVal = top8.map((c) => c.totalSpent).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Customers by Spend', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0 ? maxVal * 1.15 : 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.inverseSurface,
                    getTooltipItem: (group, _, rod, _) {
                      final idx = group.x;
                      if (idx >= 0 && idx < top8.length) {
                        return BarTooltipItem(
                          '\$${top8[idx].totalSpent.toStringAsFixed(2)}',
                          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onPrimary),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < top8.length) {
                          final name = top8[idx].customerName.length > 10 ? top8[idx].customerName.substring(0, 10) : top8[idx].customerName;
                          return Text(name, style: GoogleFonts.inter(fontSize: 8, color: AppColors.secondary));
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: top8.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.totalSpent,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      color: e.key == 0 ? AppColors.primary : AppColors.primary.withValues(alpha:0.3 + (0.1 * (8 - e.key))),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTable(List<TopCustomerDto> customers) {
    if (customers.isEmpty) return _emptyState('No customers found');

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Customer Details', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          ),
          const Divider(height: 1),
          ...customers.map((c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('#${customers.indexOf(c) + 1}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.customerName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(c.phoneNumber ?? '-', style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${c.totalSpent.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('${c.visitCount} visits', style: GoogleFonts.inter(fontSize: 10, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 8, offset: const Offset(0, 2))],
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Center(child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondary))),
    );
  }
}
