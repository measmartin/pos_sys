import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sales_provider.dart';
import 'widgets/sale_card.dart';
import 'widgets/empty_state.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});
  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String? _statusFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();

    final sales = _statusFilter == null
        ? provider.sales
        : provider.sales
            .where((s) => s.paymentStatus == _statusFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status filters
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _filterChip(null, 'All'),
                      const SizedBox(width: 8),
                      _filterChip('PAID', 'Paid'),
                      const SizedBox(width: 8),
                      _filterChip('UNPAID', 'Unpaid'),
                      const SizedBox(width: 8),
                      _filterChip('PARTIAL', 'Partial'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.calendar_month_outlined, size: 16),
                      label: Text(_rangeLabel()),
                    ),
                    if (_dateRange != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _clearDateRange,
                        child: const Text('Clear'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (provider.loading && provider.sales.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (sales.isEmpty)
                  const EmptyState()
                else
                  ...sales.map((s) => SaleCard(sale: s)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SALES LEDGER',
              style: GoogleFonts.publicSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.secondary,
              )),
          Text('Sales History',
              style: GoogleFonts.notoSerif(
                  fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month_outlined),
          color: AppColors.onSurface,
          onPressed: _pickDateRange,
        ),
        IconButton(
          icon: const Icon(Icons.refresh_outlined),
          color: AppColors.onSurface,
          onPressed: _reloadSales,
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
      helpText: 'Filter sales by date',
    );
    if (picked == null) return;

    setState(() {
      _dateRange = picked;
    });
    await _reloadSales();
  }

  Future<void> _clearDateRange() async {
    setState(() {
      _dateRange = null;
    });
    await _reloadSales();
  }

  Future<void> _reloadSales() async {
    await context.read<SalesProvider>().loadSales(
          startDate: _dateRange?.start,
          endDate: _dateRange?.end,
        );
  }

  String _rangeLabel() {
    if (_dateRange == null) return 'Date range';
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(_dateRange!.start)} - ${fmt.format(_dateRange!.end)}';
  }

  Widget _filterChip(String? status, String label) {
    final selected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = status),
      backgroundColor: AppColors.surfaceContainerHigh,
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.publicSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
      ),
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}


