import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/currency_model.dart';
import '../../data/models/sales_model.dart';
import '../../data/models/product_model.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import 'widgets/catalog_panel.dart';
import 'widgets/transaction_panel.dart';

class SalesPosScreen extends StatefulWidget {
  const SalesPosScreen({super.key});
  @override
  State<SalesPosScreen> createState() => _SalesPosScreenState();
}

class _SalesPosScreenState extends State<SalesPosScreen> {
  final _searchCtrl = TextEditingController();
  String _productSearch = '';
  bool _isTransactionCollapsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadCustomers();
      context.read<SalesProvider>().loadCurrencies();
      final pp = context.read<ProductProvider>();
      if (pp.products.isEmpty) pp.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductDetailsDto> _filteredProducts(List<ProductDetailsDto> all) {
    if (_productSearch.isEmpty) return all;
    final q = _productSearch.toLowerCase();
    return all
        .where(
          (p) =>
              p.productName.toLowerCase().contains(q) ||
              p.productCode.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesProvider>();
    final products = context.watch<ProductProvider>();
    final inTransactionProductIds = sales.cart
        .map((item) => item.productId)
        .toSet();
    final selectedCurrency = sales.selectedCurrency;

    void addToCart(ProductDetailsDto product) {
      final unit = product.units.isNotEmpty
          ? product.units.firstWhere(
              (u) => u.isDefault,
              orElse: () => product.units.first,
            )
          : null;
      if (unit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product has no unit configured')),
        );
        return;
      }
      sales.addToCart(
        CartItem(
          productId: product.productId,
          productUnitId: unit.productUnitId,
          productName: product.productName,
          unitName: unit.unitName,
          unitCode: unit.unitCode,
          imageUrl: unit.imageUrl,
          unitPrice: unit.price,
          currencySymbol: unit.currencySymbol,
          currencyCode: unit.currencyCode,
          availableUnits: product.units,
        ),
      );
      final isWideLayout = MediaQuery.sizeOf(context).width >= 900;
      if (isWideLayout && !_isTransactionCollapsed) {
        setState(() => _isTransactionCollapsed = true);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: AppColors.surfaceContainerLow,
                    child: TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.secondary,
                      indicatorColor: AppColors.primary,
                      labelStyle: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                      tabs: const [
                        Tab(text: 'Catalog'),
                        Tab(text: 'Active Transaction'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        CatalogPanel(
                          products: _filteredProducts(products.products),
                          searchCtrl: _searchCtrl,
                          onSearch: (v) => setState(() => _productSearch = v),
                          onAddToCart: addToCart,
                          inTransactionProductIds: inTransactionProductIds,
                          selectedCurrency: selectedCurrency,
                        ),
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: TransactionPanel(
                            sales: sales,
                            selectedCurrency: selectedCurrency,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: CatalogPanel(
                  products: _filteredProducts(products.products),
                  searchCtrl: _searchCtrl,
                  onSearch: (v) => setState(() => _productSearch = v),
                  onAddToCart: addToCart,
                  inTransactionProductIds: inTransactionProductIds,
                  selectedCurrency: selectedCurrency,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                width: _isTransactionCollapsed ? 56 : 340,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border(
                    left: BorderSide(
                      color: AppColors.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _isTransactionCollapsed
                      ? _CollapsedTransactionRail(
                          key: const ValueKey('collapsed-transaction'),
                          itemCount: sales.cart.length,
                          onExpand: () =>
                              setState(() => _isTransactionCollapsed = false),
                        )
                      : Column(
                          key: const ValueKey('expanded-transaction'),
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                tooltip: 'Collapse transaction',
                                icon: const Icon(
                                  Icons.keyboard_double_arrow_right,
                                ),
                                color: AppColors.secondary,
                                onPressed: () => setState(
                                  () => _isTransactionCollapsed = true,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TransactionPanel(
                                sales: sales,
                                selectedCurrency: selectedCurrency,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Amrit',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            ' POS',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Sales Terminal',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
      actions: const [],
    );
  }
}

class _CollapsedTransactionRail extends StatelessWidget {
  final int itemCount;
  final VoidCallback onExpand;

  const _CollapsedTransactionRail({
    super.key,
    required this.itemCount,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Expand transaction',
            icon: const Icon(Icons.receipt_long_rounded),
            color: AppColors.primary,
            onPressed: onExpand,
          ),
          const SizedBox(height: 4),
          Text(
            '$itemCount',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
