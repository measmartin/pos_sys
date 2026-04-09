import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sales_provider.dart';
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
      context.read<SalesProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final sales = context.watch<SalesProvider>();
    final currency = NumberFormat.currency(symbol: r'$');
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
                          color: AppColors.onSurfaceVariant.withOpacity(0.7),
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
                WeeklyBarChart(data: dash.weeklyData),
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
                      onPressed: () {},
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
                if (sales.loading)
                  const Center(child: CircularProgressIndicator())
                else if (sales.sales.isEmpty)
                  const EmptySales()
                else
                  RecentSalesTable(
                    sales: sales.sales.take(5).toList(),
                    currency: currency,
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
      backgroundColor: AppColors.background.withOpacity(0.9),
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
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Terminal A-12',
            style: GoogleFonts.publicSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
        ),
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
