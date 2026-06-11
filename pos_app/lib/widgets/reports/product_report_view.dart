import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';
import 'package:pos_app/data/models/report_model.dart';

class ProductReportView extends StatelessWidget {
  const ProductReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExportButtons(context, report),
        const SizedBox(height: 16),
        _buildTopProductsChart(report.topProducts),
        const SizedBox(height: 20),
        _buildCategoryPieChart(report.categorySales),
        const SizedBox(height: 20),
        _buildProductsTable(report.topProducts),
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

  Widget _buildTopProductsChart(List<TopProductDto> products) {
    if (products.isEmpty) return _emptyState('No product data');

    final top5 = products.take(5).toList();
    final maxVal = top5.map((p) => p.totalRevenue).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 5 Products by Revenue', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0 ? maxVal * 1.15 : 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < top5.length) {
                          final name = top5[idx].productName.length > 8 ? top5[idx].productName.substring(0, 8) : top5[idx].productName;
                          return Text(name, style: GoogleFonts.inter(fontSize: 9, color: AppColors.secondary));
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
                barGroups: top5.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.totalRevenue,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      color: AppColors.primary,
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

  Widget _buildCategoryPieChart(List<CategorySalesDto> categories) {
    if (categories.isEmpty) return _emptyState('No category data');

    final colors = [AppColors.primary, AppColors.tertiary, AppColors.error, Colors.orange, Colors.purple, Colors.teal, Colors.indigo, Colors.pink];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales by Category', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: categories.asMap().entries.map((e) {
                  return PieChartSectionData(
                    value: e.value.totalRevenue,
                    title: '${e.value.percentage.toInt()}%',
                    color: colors[e.key % colors.length],
                    radius: 60,
                    titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: categories.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.key % colors.length], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text(e.value.categoryName, style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(List<TopProductDto> products) {
    if (products.isEmpty) return _emptyState('No products found');

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Product Performance', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          ),
          const Divider(height: 1),
          ...products.take(15).map((p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('#${products.indexOf(p) + 1}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary),),
                const SizedBox(width: 12),
                Expanded(child: Text(p.productName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600))),
                if (p.categoryName != null) Text(p.categoryName!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
                const SizedBox(width: 12),
                Text('\$${p.totalRevenue.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
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
