import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../providers/product_provider.dart';
import 'product_edit_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/add_product_card.dart';
import 'widgets/empty_products.dart';
import 'widgets/error_view.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.loadProducts();
      p.loadCategories();
      p.loadUnits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: _buildContent(context, provider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProduct(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductProvider provider) {
    if (provider.loading && provider.products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null && provider.products.isEmpty) {
      return SliverFillRemaining(
        child: ErrorView(
          message: provider.error!,
          onRetry: provider.loadProducts,
        ),
      );
    }

    final List<CategoryDetailsDto?> cats = [null, ...provider.categories];
    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          'INVENTORY MANAGEMENT',
          style: GoogleFonts.publicSans(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.tertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Product Catalog',
          style: GoogleFonts.notoSerif(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: provider.setSearch,
          decoration: InputDecoration(
            hintText: 'Filter products by name or code...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.outline,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 20),
        // Category filter chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = cats[i];
              final selected = cat == null
                  ? provider.selectedCategoryId == null
                  : provider.selectedCategoryId == cat.categoryId;
              return FilterChip(
                label: Text(cat == null ? 'All' : cat.categoryName),
                selected: selected,
                onSelected: (_) => provider.setCategory(cat?.categoryId),
                backgroundColor: AppColors.surfaceContainerHigh,
                selectedColor: AppColors.primary,
                labelStyle: GoogleFonts.publicSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),
                showCheckmark: false,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Product grid
        if (provider.filtered.isEmpty)
          EmptyProducts(onAdd: () => _showAddProduct(context))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: provider.filtered.length + 1,
            itemBuilder: (_, i) {
              if (i == provider.filtered.length) {
                return AddProductCard(onTap: () => _showAddProduct(context));
              }
              return ProductCard(
                product: provider.filtered[i],
                onTap: () => _navigateToEdit(context, provider.filtered[i]),
                onDelete: () =>
                    _confirmDelete(context, provider, provider.filtered[i]),
              );
            },
          ),
      ]),
    );
  }

  void _showAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductEditScreen.create()),
    );
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    ProductDetailsDto product,
  ) async {
    final provider = context.read<ProductProvider>();
    final fullProduct = await provider.getProductById(product.productId);
    if (!context.mounted) return;

    if (fullProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to load product details'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditScreen.edit(product: fullProduct),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProductProvider provider,
    ProductDetailsDto product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${product.productName}" from catalog?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProduct(product.productId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
