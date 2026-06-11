import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/currency_model.dart';
import '../../providers/currency_provider.dart';
import 'widgets/currency_card.dart';
import 'widgets/currency_detail_sheet.dart';
import 'widgets/currency_form_sheet.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().loadCurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, provider),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: _buildContent(context, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCurrency(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, CurrencyProvider provider) {
    final hasBackButton = Navigator.of(context).canPop();
    final titleStartPadding = hasBackButton ? 72.0 : 20.0;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(titleStartPadding, 0, 20, 72),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXCHANGE RATES',
              style: GoogleFonts.publicSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.tertiary,
              ),
            ),
            Text(
              'Currencies',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        background: Container(color: AppColors.background),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            onChanged: provider.setSearch,
            decoration: InputDecoration(
              hintText: 'Search currencies...',
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.outline,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha:0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha:0.5),
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
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CurrencyProvider provider) {
    if (provider.loading && provider.currencies.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final list = provider.filtered;
    if (list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.currency_exchange_outlined,
                size: 56,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No currencies found',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first currency',
                style: GoogleFonts.inter(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => CurrencyCard(
          currency: list[i],
          onTap: () => _showCurrencyDetail(context, list[i]),
        ),
        childCount: list.length,
      ),
    );
  }

  void _showAddCurrency(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CurrencyFormSheet(),
    );
  }

  void _showCurrencyDetail(BuildContext context, CurrencyDetailsDto currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyDetailSheet(currency: currency),
    );
  }
}
