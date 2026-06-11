import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/printing/printer_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/unit_provider.dart';
import '../auth/login_screen.dart';
import '../categories/category_screen.dart';
import '../currencies/currency_screen.dart';
import '../customers/customer_screen.dart';
import '../printer/printer_settings_screen.dart';
import '../units/unit_screen.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.96),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Management',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HubCard(
                  title: 'Categories',
                  subtitle: 'Manage product categories',
                  countLabel: 'Active',
                  countValue: activeCategories.toString(),
                  icon: Icons.account_tree_outlined,
                  accent: AppColors.primary,
                  onTap: () => _openScreen(const CategoryScreen()),
                ),
                const SizedBox(height: 12),
                HubCard(
                  title: 'Units',
                  subtitle: 'Manage measurement units',
                  countLabel: 'Active',
                  countValue: activeUnits.toString(),
                  icon: Icons.straighten_outlined,
                  accent: AppColors.tertiary,
                  onTap: () => _openScreen(const UnitScreen()),
                ),
                const SizedBox(height: 12),
                HubCard(
                  title: 'Currencies',
                  subtitle: 'Manage supported currencies',
                  countLabel: 'Active',
                  countValue: activeCurrencies.toString(),
                  icon: Icons.currency_exchange_outlined,
                  accent: AppColors.primaryContainer,
                  onTap: () => _openScreen(const CurrencyScreen()),
                ),
                const SizedBox(height: 12),
                HubCard(
                  title: 'Customers',
                  subtitle: 'Open customer records',
                  countLabel: 'Module',
                  countValue: 'Open',
                  icon: Icons.group_outlined,
                  accent: AppColors.secondary,
                  onTap: () => _openScreen(const CustomerScreen()),
                ),
                const SizedBox(height: 12),
                HubCard(
                  title: 'Printer',
                  subtitle: 'Configure receipt printer',
                  countLabel: 'Status',
                  countValue: context.watch<PrinterProvider>().isConfigured ? 'Ready' : 'Not set',
                  icon: Icons.print_outlined,
                  accent: AppColors.tertiaryContainer,
                  onTap: () => _openScreen(const PrinterSettingsScreen()),
                ),
                const SizedBox(height: 12),
                HubCard(
                  title: 'Account',
                  subtitle: 'Sign out of your account',
                  countLabel: 'User',
                  countValue: context.watch<AuthProvider>().username ?? 'Unknown',
                  icon: Icons.logout_outlined,
                  accent: AppColors.error,
                  onTap: () => _confirmLogout(context),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
