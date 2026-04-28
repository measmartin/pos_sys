import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'stat_card.dart';

class StatCardsRow extends StatelessWidget {
  final double totalSales, avgOrder;
  final int txCount;
  final NumberFormat currency;
  final bool compactNumbers;
  const StatCardsRow({
    required this.totalSales,
    required this.txCount,
    required this.avgOrder,
    required this.currency,
    this.compactNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'TOTAL SALES',
                value: currency.format(totalSales),
                icon: Icons.payments_outlined,
                valueFontSize: compactNumbers ? 24 : 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'TRANSACTIONS',
                value: '$txCount',
                icon: Icons.receipt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          label: 'AVG. ORDER VALUE',
          value: currency.format(avgOrder),
          icon: Icons.calculate_outlined,
          accent: AppColors.tertiary,
          valueFontSize: compactNumbers ? 24 : 30,
        ),
      ],
    );
  }
}
