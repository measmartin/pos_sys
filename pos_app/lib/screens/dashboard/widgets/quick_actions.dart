import 'package:flutter/material.dart';
import 'action_tile.dart';

class QuickActions extends StatelessWidget {
  const QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionTile(
          label: 'New Sale',
          icon: Icons.add_shopping_cart_outlined,
          isPrimary: true,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        ActionTile(
          label: 'Add Product',
          icon: Icons.inventory_2_outlined,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        ActionTile(
          label: 'Add Customer',
          icon: Icons.person_add_outlined,
          onTap: () {},
        ),
      ],
    );
  }
}
