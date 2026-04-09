import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../categories/category_screen.dart';
import '../units/unit_screen.dart';
import '../currencies/currency_screen.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.notoSerif(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'MANAGEMENT',
            style: GoogleFonts.publicSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.category_outlined,
            title: 'Categories',
            subtitle: 'Manage product categories',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.straighten_outlined,
            title: 'Units of Measure',
            subtitle: 'Manage product units',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnitScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.currency_exchange_outlined,
            title: 'Currencies',
            subtitle: 'Manage exchange rates',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CurrencyScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'SYSTEM',
            style: GoogleFonts.publicSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Amrit POS',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: AppColors.onPrimary,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
