import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sales_model.dart';
import '../sales_invoice_detail_screen.dart';

class SaleCard extends StatelessWidget {
  final SalesDetailsDto sale;
  const SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final saleCurrency = NumberFormat.currency(
      symbol: sale.currencySymbol ?? sale.currencyCode ?? r'$',
    );
    final statusColor = sale.paymentStatus == 'PAID'
        ? AppColors.primary
        : sale.paymentStatus == 'PARTIAL'
            ? AppColors.tertiary
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _showDetail(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sale.saleNumber,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              )),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM d, yyyy  HH:mm').format(sale.saleDate),
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(saleCurrency.format(sale.totalAmount),
                            style: GoogleFonts.notoSerif(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                            )),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(sale.paymentStatus,
                              style: GoogleFonts.publicSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: statusColor,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _metaChip(Icons.person_outline,
                        sale.customerName ?? 'Walk-in'),
                    const SizedBox(width: 10),
                    _metaChip(Icons.receipt_outlined,
                        '${sale.items.length} item${sale.items.length != 1 ? 's' : ''}'),
                    if (sale.currencyCode != null) ...[
                      const SizedBox(width: 10),
                      _metaChip(Icons.currency_exchange, sale.currencyCode!),
                    ],
                    const Spacer(),
                    Text(sale.saleStatus,
                        style: GoogleFonts.publicSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                          letterSpacing: 0.8,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.outline),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
      ],
    );
  }

  void _showDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SalesInvoiceDetailScreen(sale: sale),
      ),
    );
  }
}
