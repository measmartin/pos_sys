import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/providers/report_provider.dart';
import 'package:pos_app/widgets/reports/report_date_picker.dart';
import 'package:pos_app/widgets/reports/report_tab_bar.dart';
import 'package:pos_app/widgets/reports/sales_report_view.dart';
import 'package:pos_app/widgets/reports/product_report_view.dart';
import 'package:pos_app/widgets/reports/customer_report_view.dart';
import 'package:pos_app/widgets/reports/payment_report_view.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ReportDatePicker(
                  startDate: report.startDate,
                  endDate: report.endDate,
                  preset: report.datePreset,
                  onDateChange: (start, end, preset) {
                    report.setDateRange(start, end, preset: preset);
                    report.load();
                  },
                ),
                const SizedBox(height: 16),
                ReportTabBar(
                  activeTab: report.activeTab,
                  onTabChange: (tab) {
                    report.setActiveTab(tab);
                    report.load();
                  },
                ),
                const SizedBox(height: 20),
                if (report.loading)
                  const Center(child: CircularProgressIndicator())
                else if (report.error != null)
                  _buildError(report.error!)
                else
                  _buildActiveReport(report),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha:0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load report',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurface.withValues(alpha:0.6),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.read<ReportProvider>().load(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveReport(ReportProvider report) {
    switch (report.activeTab) {
      case ReportTab.sales:
        return const SalesReportView();
      case ReportTab.products:
        return const ProductReportView();
      case ReportTab.customers:
        return const CustomerReportView();
      case ReportTab.payments:
        return const PaymentReportView();
    }
  }
}
