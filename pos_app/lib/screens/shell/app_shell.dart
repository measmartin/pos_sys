import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../management/management_hub_screen.dart';
import '../products/product_screen.dart';
import '../sales/sales_pos_screen.dart';
import '../sales/sales_history_screen.dart';
import 'widgets/nav_item.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    ProductScreen(),
    SalesPosScreen(),
    SalesHistoryScreen(),
    ManagementHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                index: 0,
                current: _index,
                icon: Icons.dashboard_customize_outlined,
                activeIcon: Icons.dashboard_customize,
                label: 'Dashboard',
                onTap: () => setState(() => _index = 0),
              ),
              NavItem(
                index: 1,
                current: _index,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Inventory',
                onTap: () => setState(() => _index = 1),
              ),
              NavItem(
                index: 2,
                current: _index,
                icon: Icons.add_shopping_cart_outlined,
                activeIcon: Icons.add_shopping_cart,
                label: 'POS',
                onTap: () => setState(() => _index = 2),
                isPrimary: true,
              ),
              NavItem(
                index: 3,
                current: _index,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Sales',
                onTap: () => setState(() => _index = 3),
              ),
              NavItem(
                index: 4,
                current: _index,
                icon: Icons.settings_applications_outlined,
                activeIcon: Icons.settings_applications,
                label: 'Manage',
                onTap: () => setState(() => _index = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
