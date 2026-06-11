import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/currency_model.dart';
import '../../../data/models/product_model.dart';
import '../../../utils/currency_utils.dart';

class CatalogCard extends StatelessWidget {
  final ProductDetailsDto product;
  final VoidCallback onTap;
  final bool isInTransaction;
  final CurrencyDetailsDto? selectedCurrency;

  const CatalogCard({
    required this.product,
    required this.onTap,
    this.isInTransaction = false,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final unit = product.units.isNotEmpty
        ? product.units.firstWhere(
            (u) => u.isDefault,
            orElse: () => product.units.first,
          )
        : null;
    final rate = selectedCurrency == null || selectedCurrency!.isBaseCurrency
        ? 1.0
        : selectedCurrency!.exchangeRate;
    final formatter = makeCurrencyFormat(
      selectedCurrency?.currencyCode,
      selectedCurrency?.currencySymbol ??
          selectedCurrency?.currencyCode ??
          unit?.currencySymbol ??
          unit?.currencyCode ??
          r'$',
    );

    return Material(
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isInTransaction
              ? AppColors.primary.withValues(alpha:0.65)
              : AppColors.outlineVariant.withValues(alpha:0.2),
          width: isInTransaction ? 1.2 : 0.7,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                        ),
                        child: unit?.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: unit!.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 32,
                                    color: AppColors.outlineVariant,
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 32,
                                    color: AppColors.outlineVariant,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 32,
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                      ),
                    ),
                    if (isInTransaction)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 10,
                                color: AppColors.onPrimary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'In Cart',
                                style: GoogleFonts.publicSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.categoryName?.toUpperCase() ?? '',
                style: GoogleFonts.publicSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.tertiary,
                ),
              ),
              Text(
                product.productName,
                style: GoogleFonts.notoSerif(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                unit != null
                    ? formatter.format(roundForCurrency(unit.price * rate, selectedCurrency?.currencyCode))
                    : 'N/A',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
