import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';
import 'package:pos_app/data/models/report_model.dart';
import 'package:intl/intl.dart';

class SalesReportView extends StatelessWidget {
  const SalesReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    final summary = report.salesSummary;
    final dailySales = report.dailySales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary != null) _buildSummaryCards(summary),
        const SizedBox(height: 20),
        _buildChart(dailySales, summary),
        const SizedBox(height: 20),
        _buildExportButtons(context, report),
        const SizedBox(height: 16),
        _buildSalesTable(report.salesExport),
      ],
    );
  }

  Widget _buildSummaryCards(SalesSummaryDto summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('Revenue', '${summary.currencySymbol ?? '\$'}${summary.totalRevenue.toStringAsFixed(2)}', Icons.attach_money, AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Transactions', '${summary.transactionCount}', Icons.receipt_long, AppColors.tertiary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard('Avg Order', '${summary.currencySymbol ?? '\$'}${summary.avgOrderValue.toStringAsFixed(2)}', Icons.trending_up, AppColors.secondary)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Discount', '${summary.currencySymbol ?? '\$'}${summary.totalDiscount.toStringAsFixed(2)}', Icons.discount, AppColors.error)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.publicSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.notoSerif(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildChart(List<DailySalesDto> dailySales, SalesSummaryDto? summary) {
    if (dailySales.isEmpty) {
      return _emptyState('No sales data for this period');
    }

    final maxVal = dailySales.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
    final spots = dailySales.asMap().entries.map((e) => BarChartGroupData(
      x: e.key,
      barRods: [
        BarChartRodData(
          toY: e.value.revenue,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          color: e.key == dailySales.length - 1 ? AppColors.primary : AppColors.primary.withValues(alpha:0.4),
        ),
      ],
    )).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Revenue', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
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
                      if (idx >= 0 && idx < dailySales.length) {
                        return BarTooltipItem(
                          '${summary?.currencySymbol ?? '\$'}${dailySales[idx].revenue.toStringAsFixed(2)}',
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
                        if (idx >= 0 && idx < dailySales.length && dailySales.length <= 31) {
                          return Text(
                            DateFormat('dd').format(dailySales[idx].date),
                            style: GoogleFonts.inter(fontSize: 9, color: AppColors.secondary),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxVal > 0 ? maxVal / 4 : 25),
                borderData: FlBorderData(show: false),
                barGroups: spots,
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildSalesTable(List<SalesExportDto> sales) {
    if (sales.isEmpty) return _emptyState('No sales found');

    final displaySales = sales.take(20).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Recent Sales', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          ),
          const Divider(height: 1),
          ...displaySales.map((s) => _saleRow(s)),
          if (sales.length > 20)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text('Showing 20 of ${sales.length}. Export to see all.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _saleRow(SalesExportDto s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(s.saleNumber, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(s.customerName ?? 'Walk-in', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary))),
          Expanded(
            flex: 2,
            child: Text(
              '\$${s.totalAmount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (s.paymentStatus == 'PAID' ? Colors.green : s.paymentStatus == 'PARTIAL' ? Colors.orange : Colors.red).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(s.paymentStatus, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: s.paymentStatus == 'PAID' ? Colors.green : s.paymentStatus == 'PARTIAL' ? Colors.orange : Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondary))),
    );
  }
}
