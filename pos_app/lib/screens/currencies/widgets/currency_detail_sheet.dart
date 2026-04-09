import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/currency_model.dart';
import '../../../providers/currency_provider.dart';
import 'currency_detail_row.dart';
import 'currency_form_sheet.dart';

class CurrencyDetailSheet extends StatelessWidget {
  final CurrencyDetailsDto currency;
  const CurrencyDetailSheet({required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: currency.isBaseCurrency
                  ? AppColors.tertiaryFixed
                  : AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                currency.currencySymbol ??
                    currency.currencyCode.substring(0, 1),
                style: GoogleFonts.notoSerif(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: currency.isBaseCurrency
                      ? AppColors.tertiary
                      : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currency.currencyName,
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              currency.currencyCode,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Created ${DateFormat('MMMM yyyy').format(currency.createdAt)}',
            style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Divider(),
          CurrencyDetailRow('Exchange Rate', currency.exchangeRate.toStringAsFixed(4)),
          CurrencyDetailRow('Symbol', currency.currencySymbol ?? '—'),
          CurrencyDetailRow('Status', currency.isActive ? 'Active' : 'Inactive'),
          CurrencyDetailRow(
            'Type',
            currency.isBaseCurrency ? 'Base Currency' : 'Foreign Currency',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditCurrency(context, currency);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currency.isBaseCurrency
                      ? null
                      : () => _deleteCurrency(context, currency),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditCurrency(BuildContext context, CurrencyDetailsDto currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyFormSheet(currency: currency),
    );
  }

  Future<void> _deleteCurrency(
    BuildContext context,
    CurrencyDetailsDto currency,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Currency'),
        content: Text(
          'Are you sure you want to delete "${currency.currencyName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<CurrencyProvider>().deleteCurrency(
        currency.currencyId,
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Currency deleted' : 'Failed to delete currency',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
          ),
        );
      }
    }
  }
}
