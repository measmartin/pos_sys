import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../shell/app_shell.dart';
import '../settings/settings_screen.dart';
import 'widgets/stat_cards_row.dart';
import 'widgets/weekly_bar_chart.dart';
import 'widgets/quick_actions.dart';
import 'widgets/empty_sales.dart';
import 'widgets/recent_sales_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final currency = NumberFormat.currency(
      symbol: dash.activeCurrencySymbol,
      decimalDigits: dash.currencyView == DashboardCurrencyView.khr ? 0 : 2,
    );
    final now = DateTime.now();
    final dateStr = DateFormat(
      'EEEE, d\'${_ordinal(now.day)}\' of MMMM, yyyy',
    ).format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Editorial header
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY LEDGER',
                        style: GoogleFonts.publicSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Daily Overview',
                        style: GoogleFonts.notoSerif(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateStr,
                        style: GoogleFonts.notoSerif(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stat cards
                if (dash.loading)
                  const Center(child: CircularProgressIndicator())
                else
                  StatCardsRow(
                    totalSales: dash.totalSalesToday,
                    txCount: dash.transactionCount,
                    avgOrder: dash.avgOrderValue,
                    currency: currency,
                    compactNumbers:
                        dash.currencyView == DashboardCurrencyView.khr,
                  ),

                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<DashboardCurrencyView>(
                    segments: const [
                      ButtonSegment(
                        value: DashboardCurrencyView.usd,
                        label: Text('USD'),
                      ),
                      ButtonSegment(
                        value: DashboardCurrencyView.khr,
                        label: Text('KHR'),
                      ),
                      ButtonSegment(
                        value: DashboardCurrencyView.both,
                        label: Text('BOTH'),
                      ),
                    ],
                    selected: {dash.currencyView},
                    onSelectionChanged: (selection) =>
                        dash.setCurrencyView(selection.first),
                  ),
                ),
                if (dash.currencyView == DashboardCurrencyView.both)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dash.bothRateLabel == null
                            ? 'Combined values shown as ${dash.activeCurrencyLabel}'
                            : 'Combined values shown as ${dash.activeCurrencyLabel} • ${dash.bothRateLabel}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                // Weekly chart title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Weekly Performance',
                      style: GoogleFonts.notoSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _weekRange(),
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                WeeklyBarChart(
                  data: dash.weeklyData,
                  currencySymbol: dash.activeCurrencySymbol,
                ),
                const SizedBox(height: 32),

                // Quick actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.notoSerif(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const QuickActions(),
                const SizedBox(height: 32),

                // Recent sales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Sales',
                      style: GoogleFonts.notoSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AppShell.tabNotifier.value = 3;
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.publicSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (dash.loading)
                  const Center(child: CircularProgressIndicator())
                else if (dash.recentSales.isEmpty)
                  const EmptySales()
                else
                  RecentSalesTable(
                    sales: dash.recentSales.take(5).toList(),
                  ),
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
      backgroundColor: AppColors.background.withValues(alpha:0.9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Amrit',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            ' POS',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.onSurface,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _weekRange() {
    final now = DateTime.now();
    final mon = now.subtract(Duration(days: now.weekday - 1));
    final sun = mon.add(const Duration(days: 6));
    final fmt = DateFormat('MMM d');
    return '${fmt.format(mon)} — ${fmt.format(sun)}';
  }
}
