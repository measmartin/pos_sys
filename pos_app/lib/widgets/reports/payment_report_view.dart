import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';
import 'package:pos_app/data/models/report_model.dart';

class PaymentReportView extends StatelessWidget {
  const PaymentReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExportButtons(context, report),
        const SizedBox(height: 16),
        _buildPaymentPieChart(report.paymentBreakdown),
        const SizedBox(height: 20),
        _buildPaymentSummary(report.paymentBreakdown),
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

  Widget _buildPaymentPieChart(List<PaymentBreakdownDto> payments) {
    if (payments.isEmpty) return _emptyState('No payment data');

    final colors = {
      'PAID': Colors.green,
      'UNPAID': Colors.red,
      'PARTIAL': Colors.orange,
    };

    final totalAmount = payments.fold<double>(0, (sum, p) => sum + p.totalAmount);
    final totalCount = payments.fold<int>(0, (sum, p) => sum + p.count);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Distribution', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('$totalCount', style: GoogleFonts.notoSerif(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                  Text('Transactions', style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
                ],
              ),
              Column(
                children: [
                  Text('\$${totalAmount.toStringAsFixed(2)}', style: GoogleFonts.notoSerif(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text('Total Revenue', style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: payments.map((p) {
                  return PieChartSectionData(
                    value: p.totalAmount,
                    title: '${p.percentage.toInt()}%',
                    color: colors[p.paymentStatus] ?? AppColors.secondary,
                    radius: 70,
                    titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 3,
                centerSpaceRadius: 35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: payments.map((p) {
              final color = colors[p.paymentStatus] ?? AppColors.secondary;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text(p.paymentStatus, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(width: 4),
                  Text('(${p.count})', style: GoogleFonts.inter(fontSize: 10, color: AppColors.secondary)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(List<PaymentBreakdownDto> payments) {
    if (payments.isEmpty) return _emptyState('No payment data');

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Payment Breakdown', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.secondary)),
          ),
          const Divider(height: 1),
          ...payments.map((p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: _paymentColor(p.paymentStatus),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(p.paymentStatus, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${p.totalAmount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('${p.count} transactions', style: GoogleFonts.inter(fontSize: 10, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'PAID': return Colors.green;
      case 'UNPAID': return Colors.red;
      case 'PARTIAL': return Colors.orange;
      default: return AppColors.secondary;
    }
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
