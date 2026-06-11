import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/printing/printer_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/currency_model.dart';
import '../../../providers/sales_provider.dart';
import '../../../utils/currency_utils.dart';
import 'cart_item_tile.dart';
import 'total_row.dart';

class TransactionPanel extends StatefulWidget {
  final SalesProvider sales;
  final CurrencyDetailsDto? selectedCurrency;
  const TransactionPanel({
    required this.sales,
    required this.selectedCurrency,
  });
  @override
  State<TransactionPanel> createState() => _TransactionPanelState();
}

class _TransactionPanelState extends State<TransactionPanel> {
  final _discountAmtCtrl = TextEditingController();
  final _discountPctCtrl = TextEditingController();
  final _amtPaidCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _amountPaidManuallyEdited = false;
  bool _isPatronSectionExpanded = true;
  bool _isCheckoutSectionExpanded = true;

  @override
  void initState() {
    super.initState();
    widget.sales.addListener(_onSalesChanged);
    _phoneCtrl.text = widget.sales.customerPhone;
    _syncAmountPaidDefault(widget.sales);
  }

  @override
  void didUpdateWidget(covariant TransactionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sales != widget.sales) {
      oldWidget.sales.removeListener(_onSalesChanged);
      widget.sales.addListener(_onSalesChanged);
    }
  }

  void _onSalesChanged() {
    if (!mounted) return;
    final s = widget.sales;
    if (_phoneCtrl.text != s.customerPhone) {
      _phoneCtrl.text = s.customerPhone;
      _phoneCtrl.selection = TextSelection.collapsed(offset: _phoneCtrl.text.length);
    }
    _syncAmountPaidDefault(s);
  }

  @override
  void dispose() {
    widget.sales.removeListener(_onSalesChanged);
    _discountAmtCtrl.dispose();
    _discountPctCtrl.dispose();
    _amtPaidCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sales;
    final selectedCurrency = widget.selectedCurrency;
    final c = makeCurrencyFormat(
      selectedCurrency?.currencyCode,
      selectedCurrency?.currencySymbol ?? selectedCurrency?.currencyCode ?? r'$',
    );
    final rate = s.selectedCurrencyRate;
    final currencyCode = selectedCurrency?.currencyCode;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Transaction',
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '#TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}  •  ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (s.cart.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  color: AppColors.error,
                  onPressed: s.clearCart,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.errorContainer.withValues(alpha:0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Currency selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: DropdownButtonFormField<int?>(
            initialValue: s.selectedCurrency?.currencyId,
            decoration: InputDecoration(
              labelText: 'Currency',
              prefixIcon: const Icon(
                Icons.currency_exchange,
                color: AppColors.tertiary,
                size: 18,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
            items: s.currencies
                .map(
                  (currency) => DropdownMenuItem<int?>(
                    value: currency.currencyId,
                    child: Text(
                      '${currency.currencyCode} • ${currency.currencyName}',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (currencyId) {
              if (currencyId == null) return;
              final currency = s.currencies.firstWhere(
                (c) => c.currencyId == currencyId,
              );
              s.setSelectedCurrency(currency);
              _amountPaidManuallyEdited = false;
              _discountAmtCtrl.clear();
              _discountPctCtrl.clear();
              _amtPaidCtrl.clear();
            },
          ),
        ),

        // Customer selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'SELECT PATRON',
                    style: GoogleFonts.publicSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.secondary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _isPatronSectionExpanded
                        ? 'Collapse patron'
                        : 'Expand patron',
                    onPressed: () => setState(
                      () => _isPatronSectionExpanded = !_isPatronSectionExpanded,
                    ),
                    icon: Icon(
                      _isPatronSectionExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                    ),
                    color: AppColors.secondary,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (_isPatronSectionExpanded) ...[
                const SizedBox(height: 6),
                DropdownButtonFormField<int?>(
                  initialValue: s.selectedCustomer?.customerId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.tertiary,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                  hint: Text(
                    'Walk-in Patron',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Walk-in Patron',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    ...s.customers.map(
                      (c) => DropdownMenuItem(
                        value: c.customerId,
                        child: Text(
                          c.displayName,
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    s.setSelectedCustomer(
                      v == null
                          ? null
                          : s.customers.firstWhere((c) => c.customerId == v),
                    );
                    _phoneCtrl.text = s.customerPhone;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Required for online orders',
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.tertiary,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                  onChanged: s.setCustomerPhone,
                ),
              ],
            ],
          ),
        ),

        // Cart items
        Expanded(
          child: s.cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 48,
                        color: AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cart is empty',
                        style: GoogleFonts.notoSerif(
                          color: AppColors.secondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a product to add it',
                        style: GoogleFonts.inter(
                          color: AppColors.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  itemCount: s.cart.length,
                  itemBuilder: (_, i) => CartItemTile(
                    item: s.cart[i],
                    currency: c,
                    currencyRate: rate,
                    currencyCode: currencyCode,
                    onRemove: () => s.removeFromCart(i),
                    onQtyChange: (q) => s.updateQuantity(i, q),
                    onUnitChange: (unitId) => s.updateCartItemUnit(i, unitId),
                  ),
                ),
        ),

        // Discount + totals
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border(
              top: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.4)),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'CHECKOUT',
                    style: GoogleFonts.publicSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.secondary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _isCheckoutSectionExpanded
                        ? 'Collapse checkout'
                        : 'Expand checkout',
                    onPressed: () => setState(
                      () =>
                          _isCheckoutSectionExpanded = !_isCheckoutSectionExpanded,
                    ),
                    icon: Icon(
                      _isCheckoutSectionExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                    ),
                    color: AppColors.secondary,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.hardEdge,
                  child: _isCheckoutSectionExpanded
                      ? Column(
                          children: [
                            // Discounts row
                            if (s.cart.isNotEmpty) ...[
                              Row(
                                children: [
                                  Text(
                                    'DISCOUNTS',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _discountAmtCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Amount',
                                        prefixText: '${selectedCurrency?.currencySymbol ?? '\$'} ',
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.outlineVariant.withValues(alpha:0.5),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.outlineVariant.withValues(alpha:0.4),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      onChanged: (v) {
                                        final val = double.tryParse(v) ?? 0;
                                        if (val < 0) return;
                                        if (val > s.cartSubtotal) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Discount cannot exceed subtotal'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                          return;
                                        }
                                        s.setDiscount(
                                          amount: val,
                                          percentage: 0,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _discountPctCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Percent',
                                        suffixText: '%',
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.outlineVariant.withValues(alpha:0.5),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.outlineVariant.withValues(alpha:0.4),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      onChanged: (v) {
                                        final val = double.tryParse(v) ?? 0;
                                        if (val < 0 || val > 100) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Discount percentage must be between 0 and 100'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                          return;
                                        }
                                        s.setDiscount(
                                          amount: 0,
                                          percentage: val,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            TotalRow('Subtotal', c.format(s.cartSubtotal)),
                            if (s.effectiveDiscount > 0)
                              TotalRow(
                                'Discount',
                                '−${c.format(s.effectiveDiscount)}',
                                isDiscount: true,
                              ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  c.format(s.cartTotal),
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (s.cart.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                initialValue: s.paymentStatus,
                                decoration: InputDecoration(
                                  labelText: 'Payment Status',
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.outlineVariant.withValues(alpha:0.5),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.outlineVariant.withValues(alpha:0.4),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.primary),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'PAID', child: Text('Completed')),
                                  DropdownMenuItem(value: 'PARTIAL', child: Text('Partial')),
                                  DropdownMenuItem(value: 'UNPAID', child: Text('Unpaid')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    s.setPaymentStatus(value);
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _amtPaidCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Amount Paid',
                                  prefixText: '${selectedCurrency?.currencySymbol ?? '\$'} ',
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.outlineVariant.withValues(alpha:0.5),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.outlineVariant.withValues(alpha:0.4),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.primary),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                onChanged: (v) {
                                  final val = double.tryParse(v) ?? 0;
                                  if (val < 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Amount paid cannot be negative'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }
                                  _amountPaidManuallyEdited = true;
                                  s.setAmountPaid(val);
                                },
                              ),
                              if (s.changeAmount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Change: ',
                                        style: GoogleFonts.inter(
                                          color: AppColors.secondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        c.format(s.changeAmount),
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  c.format(s.cartTotal),
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: s.cart.isEmpty || s.loading ? null : _process,
                  icon: s.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.payments_outlined),
                  label: Text(
                    s.loading ? 'Processing...' : 'Process Payment',
                    style: GoogleFonts.notoSerif(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColors.primary.withValues(alpha:0.3),
                    elevation: 4,
                  ),
                ),
               ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _process() async {
    final sales = widget.sales;
    if (sales.selectedCurrency == null && sales.currencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No currency configured. Check API connection.'),
        ),
      );
      return;
    }
    final phone = sales.customerPhone.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is required to complete this sale.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must contain at least 6 digits.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final result = await sales.completeSale();
    if (!mounted) return;
    if (result != null) {
      _discountAmtCtrl.clear();
      _discountPctCtrl.clear();
      _amtPaidCtrl.clear();
      _phoneCtrl.clear();
      _amountPaidManuallyEdited = false;
      final selCur = widget.selectedCurrency;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sale Complete — ${result.saleNumber} • ${formatAmount(result.totalAmount, selCur?.currencyCode, selCur?.currencySymbol ?? selCur?.currencyCode ?? r'$')}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      final printer = context.read<PrinterProvider>();
      if (printer.autoPrint && printer.isConfigured) {
        printer.printReceipt(result);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sales.error ?? 'Sale failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _syncAmountPaidDefault(SalesProvider sales) {
    if (sales.cart.isEmpty) {
      if (_amtPaidCtrl.text.isNotEmpty) {
        _amtPaidCtrl.clear();
      }
      _amountPaidManuallyEdited = false;
      return;
    }

    if (!_amountPaidManuallyEdited || sales.amountPaid <= 0) {
      final defaultValue = sales.paymentStatus == 'UNPAID'
          ? 0.0
          : sales.cartTotal;
      final formatted = defaultValue.toStringAsFixed(2);
      if (_amtPaidCtrl.text != formatted) {
        _amtPaidCtrl.text = formatted;
        _amtPaidCtrl.selection = TextSelection.collapsed(
          offset: _amtPaidCtrl.text.length,
        );
      }
      if (sales.amountPaid != defaultValue) {
        sales.setAmountPaid(defaultValue);
      }
    }
  }

  }
