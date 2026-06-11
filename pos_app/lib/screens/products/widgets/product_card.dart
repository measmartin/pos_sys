import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductDetailsDto product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  String _formatPrice(double price, ProductUnitDetailsDto unit) {
    final formatter = NumberFormat.currency(
      symbol: unit.currencySymbol ?? unit.currencyCode ?? r'$',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final defaultUnit = product.units.isNotEmpty
        ? product.units.firstWhere(
            (u) => u.isDefault,
            orElse: () => product.units.first,
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.surfaceContainer,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  if (product.units.isNotEmpty &&
                      product.units.first.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: product.units.first.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(),
                      errorWidget: (context, url, error) => const SizedBox(),
                    ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        product.categoryName ?? 'N/A',
                        style: GoogleFonts.publicSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.productCode} · ${product.categoryName ?? ""}',
                    style: GoogleFonts.publicSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.productName,
                    style: GoogleFonts.notoSerif(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Variants Display
                  if (product.units.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VARIANTS',
                          style: GoogleFonts.publicSans(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: product.units.map((unit) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: unit.isDefault
                                    ? AppColors.primary.withValues(alpha:0.15)
                                    : AppColors.surfaceContainer,
                                border: Border.all(
                                  color: unit.isDefault
                                      ? AppColors.primary
                                      : AppColors.outlineVariant.withValues(alpha:0.3),
                                  width: unit.isDefault ? 1 : 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    unit.unitCode ?? unit.unitName ?? 'Unit',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    _formatPrice(unit.price, unit),
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  else
                    Text(
                      'No variants',
                      style: GoogleFonts.publicSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AppColors.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
