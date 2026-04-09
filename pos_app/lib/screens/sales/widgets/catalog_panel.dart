import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/currency_model.dart';
import '../../../data/models/product_model.dart';
import 'catalog_card.dart';

class CatalogPanel extends StatelessWidget {
  final List<ProductDetailsDto> products;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final ValueChanged<ProductDetailsDto> onAddToCart;
  final Set<int> inTransactionProductIds;
  final CurrencyDetailsDto? selectedCurrency;

  const CatalogPanel({
    required this.products,
    required this.searchCtrl,
    required this.onSearch,
    required this.onAddToCart,
    required this.inTransactionProductIds,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Catalog',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.outline,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text(
                    'No products',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => CatalogCard(
                    product: products[i],
                    onTap: () => onAddToCart(products[i]),
                    isInTransaction: inTransactionProductIds.contains(
                      products[i].productId,
                    ),
                    selectedCurrency: selectedCurrency,
                  ),
                ),
        ),
      ],
    );
  }
}
