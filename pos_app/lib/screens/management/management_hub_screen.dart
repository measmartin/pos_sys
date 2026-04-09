import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/category_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/unit_provider.dart';
import '../categories/category_screen.dart';
import '../currencies/currency_screen.dart';
import '../customers/customer_screen.dart';
import '../units/unit_screen.dart';
import 'widgets/section_intro.dart';
import 'widgets/footer_mark.dart';
import 'widgets/hub_card.dart';

class ManagementHubScreen extends StatefulWidget {
  const ManagementHubScreen({super.key});

  @override
  State<ManagementHubScreen> createState() => _ManagementHubScreenState();
}

class _ManagementHubScreenState extends State<ManagementHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      context.read<UnitProvider>().loadUnits();
      context.read<CurrencyProvider>().loadCurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final units = context.watch<UnitProvider>().units;
    final currencies = context.watch<CurrencyProvider>().currencies;

    final activeCategories = categories.where((c) => c.isActive).length;
    final activeUnits = units.where((u) => u.isActive).length;
    final activeCurrencies = currencies.where((c) => c.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 120,
            right: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: -100,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.05),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 142,
                backgroundColor: AppColors.background.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Amrit',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM MANAGEMENT',
                        style: GoogleFonts.publicSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: AppColors.tertiary,
                        ),
                      ),
                      Text(
                        'Office of Records',
                        style: GoogleFonts.notoSerif(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SectionIntro(),
                    const SizedBox(height: 14),
                    HubCard(
                      title: 'Metadata Hierarchy',
                      subtitle:
                          'Define and organize product taxonomy for retrieval',
                      countLabel: 'Active Categories',
                      countValue: activeCategories.toString(),
                      icon: Icons.account_tree_outlined,
                      accent: AppColors.primary,
                      onTap: () => _openScreen(const CategoryScreen()),
                    ),
                    const SizedBox(height: 12),
                    HubCard(
                      title: 'Archival Measures',
                      subtitle:
                          'Standardize measurement units for inventory precision',
                      countLabel: 'Defined Units',
                      countValue: activeUnits.toString(),
                      icon: Icons.straighten_outlined,
                      accent: AppColors.tertiary,
                      onTap: () => _openScreen(const UnitScreen()),
                    ),
                    const SizedBox(height: 12),
                    HubCard(
                      title: 'Exchange Ledger',
                      subtitle:
                          'Manage active currencies and valuation settings',
                      countLabel: 'Active Currencies',
                      countValue: activeCurrencies.toString(),
                      icon: Icons.currency_exchange_outlined,
                      accent: AppColors.primaryContainer,
                      onTap: () => _openScreen(const CurrencyScreen()),
                    ),
                    const SizedBox(height: 12),
                    HubCard(
                      title: 'Patron Directory',
                      subtitle: 'Access customer records and profile insights',
                      countLabel: 'CRM Module',
                      countValue: 'Open',
                      icon: Icons.group_outlined,
                      accent: AppColors.secondary,
                      onTap: () => _openScreen(const CustomerScreen()),
                    ),
                    const SizedBox(height: 20),
                    const FooterMark(),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
