import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sales_model.dart';
import '../../../utils/currency_utils.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final NumberFormat currency;
  final double currencyRate;
  final String? currencyCode;
  final VoidCallback onRemove;
  final ValueChanged<double> onQtyChange;
  final ValueChanged<int> onUnitChange;

  const CartItemTile({
    required this.item,
    required this.currency,
    required this.currencyRate,
    this.currencyCode,
    required this.onRemove,
    required this.onQtyChange,
    required this.onUnitChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: AppColors.outlineVariant,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: AppColors.outlineVariant,
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: AppColors.outlineVariant,
                  ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.notoSerif(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currency.format(roundForCurrency(item.lineTotal * currencyRate, currencyCode)),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (item.availableUnits.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: item.productUnitId,
                        isDense: true,
                        iconSize: 16,
                        style: GoogleFonts.publicSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        items: item.availableUnits
                            .map(
                              (u) => DropdownMenuItem<int>(
                                value: u.productUnitId,
                                  child: Text(
                                    '${u.unitCode ?? u.unitName ?? 'Unit'} · ${currency.format(roundForCurrency(u.price * currencyRate, currencyCode))}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) onUnitChange(value);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Qty control
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha:0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => onQtyChange(item.quantity - 1),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.remove,
                      size: 14,
                      color: AppColors.outline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onQtyChange(item.quantity + 1),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add, size: 14, color: AppColors.outline),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.error,
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
