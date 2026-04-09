import 'package:flutter/material.dart';
import '../data/models/sales_model.dart';
import '../data/models/customer_model.dart';
import '../data/models/currency_model.dart';
import '../data/services/api_service.dart';

class SalesProvider extends ChangeNotifier {
  final ApiService _api;
  SalesProvider(this._api);

  List<SalesDetailsDto> _sales = [];
  List<CustomerDetailsDto> _customers = [];
  List<CurrencyDetailsDto> _currencies = [];
  bool _loading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  // POS Cart state
  final List<CartItem> _cart = [];
  CustomerDetailsDto? _selectedCustomer;
  String _customerPhone = '';
  CurrencyDetailsDto? _selectedCurrency;
  String _paymentStatus = 'PAID';
  double _discountAmount = 0;
  double _discountPercentage = 0;
  double _amountPaid = 0;

  List<SalesDetailsDto> get sales => _sales;
  List<CustomerDetailsDto> get customers => _customers;
  List<CurrencyDetailsDto> get currencies => _currencies;
  bool get loading => _loading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  List<CartItem> get cart => _cart;
  CustomerDetailsDto? get selectedCustomer => _selectedCustomer;
  String get customerPhone => _customerPhone;
  CurrencyDetailsDto? get selectedCurrency => _selectedCurrency;
  String get paymentStatus => _paymentStatus;
  double get discountAmount => _discountAmount;
  double get discountPercentage => _discountPercentage;
  double get amountPaid => _amountPaid;

  double get selectedCurrencyRate {
    if (_selectedCurrency == null || _selectedCurrency!.isBaseCurrency) {
      return 1.0;
    }
    return _selectedCurrency!.exchangeRate;
  }

  String get selectedCurrencySymbol =>
      _selectedCurrency?.currencySymbol ?? _selectedCurrency?.currencyCode ?? r'$';

  double convertToSelectedCurrency(double baseAmount) {
    return baseAmount * selectedCurrencyRate;
  }

  double get cartSubtotal =>
      convertToSelectedCurrency(_cart.fold(0.0, (sum, item) => sum + item.lineSubtotal));

  double get effectiveDiscount {
    if (_discountAmount > 0) return _discountAmount;
    if (_discountPercentage > 0) {
      return cartSubtotal * _discountPercentage / 100;
    }
    return 0;
  }

  double get cartTotal => cartSubtotal - effectiveDiscount;
  double get changeAmount =>
      (_amountPaid - cartTotal).clamp(0, double.infinity);
  int get cartItemCount => _cart.fold(0, (sum, i) => sum + i.quantity.toInt());

  void addToCart(CartItem item) {
    final idx = _cart.indexWhere(
      (c) =>
          c.productId == item.productId &&
          c.productUnitId == item.productUnitId,
    );
    if (idx >= 0) {
      _cart[idx].quantity += 1;
    } else {
      _cart.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, double qty) {
    if (qty <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index].quantity = qty;
    }
    notifyListeners();
  }

  void updateCartItemUnit(int index, int productUnitId) {
    if (index < 0 || index >= _cart.length) return;
    final item = _cart[index];
    final unit = item.availableUnits.firstWhere(
      (u) => u.productUnitId == productUnitId,
      orElse: () => item.availableUnits.first,
    );

    final existingIdx = _cart.indexWhere(
      (c) =>
          c.productId == item.productId &&
          c.productUnitId == unit.productUnitId &&
          c != item,
    );

    if (existingIdx >= 0) {
      _cart[existingIdx].quantity += item.quantity;
      _cart.removeAt(index);
    } else {
      item.productUnitId = unit.productUnitId;
      item.unitName = unit.unitName;
      item.unitCode = unit.unitCode;
      item.unitPrice = unit.price;
      item.imageUrl = unit.imageUrl;
      item.currencySymbol = unit.currencySymbol;
      item.currencyCode = unit.currencyCode;
    }

    notifyListeners();
  }

  void setSelectedCustomer(CustomerDetailsDto? c) {
    _selectedCustomer = c;
    _customerPhone = c?.phoneNumber?.trim() ?? '';
    notifyListeners();
  }

  void setCustomerPhone(String value) {
    _customerPhone = value;
    notifyListeners();
  }

  void setSelectedCurrency(CurrencyDetailsDto? c) {
    _selectedCurrency = c;
    notifyListeners();
  }

  void setPaymentStatus(String status) {
    _paymentStatus = status;
    notifyListeners();
  }

  void setDiscount({double? amount, double? percentage}) {
    _discountAmount = amount ?? 0;
    _discountPercentage = percentage ?? 0;
    notifyListeners();
  }

  void setAmountPaid(double v) {
    _amountPaid = v;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _selectedCustomer = null;
    _customerPhone = '';
    _paymentStatus = 'PAID';
    _discountAmount = 0;
    _discountPercentage = 0;
    _amountPaid = 0;
    notifyListeners();
  }

  Future<void> loadSales({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _loading = true;
    _error = null;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
    try {
      final raw = (startDate != null && endDate != null)
          ? await _api.getSalesByDateRange(
              startDate: startDate,
              endDate: endDate,
            )
          : await _api.getSales(
              pageSize: 50,
              search: search,
              status: status,
            );
      _sales = raw
          .map((e) => SalesDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomers() async {
    try {
      final raw = await _api.getCustomers(pageSize: 200);
      _customers = raw
          .map((e) => CustomerDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCurrencies() async {
    try {
      final raw = await _api.getCurrencies();
      _currencies = raw
          .map((e) => CurrencyDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
      if (_selectedCurrency == null && _currencies.isNotEmpty) {
        _selectedCurrency = _currencies.firstWhere(
          (c) => c.isBaseCurrency,
          orElse: () => _currencies.first,
        );
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<SalesDetailsDto?> completeSale() async {
    if (_cart.isEmpty) return null;
    if (_selectedCurrency == null) return null;
    if (_customerPhone.trim().isEmpty) {
      _error = 'Phone number is required for online sales.';
      notifyListeners();
      return null;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final dto = CreateSalesDto(
        customerId: _selectedCustomer?.customerId,
        phoneNumber: _customerPhone.trim(),
        currencyId: _selectedCurrency!.currencyId,
        amountPaid: _paymentStatus == 'UNPAID'
            ? 0
            : (_amountPaid > 0 ? _amountPaid : cartTotal),
        paymentStatus: _paymentStatus,
        saleStatus: 'COMPLETED',
        discountAmount: _discountAmount > 0 ? _discountAmount : null,
        discountPercentage: _discountPercentage > 0
            ? _discountPercentage
            : null,
        items: _cart
            .map(
              (c) => CreateSalesItemDto(
                productId: c.productId,
                productUnitId: c.productUnitId,
                quantity: c.quantity,
                unitPrice: convertToSelectedCurrency(c.unitPrice),
                discountAmount: c.discountAmount,
                discountPercentage: c.discountPercentage,
              ),
            )
            .toList(),
      );
      final raw = await _api.createSale(dto.toJson());
      final sale = SalesDetailsDto.fromJson(raw);
      _sales.insert(0, sale);
      clearCart();
      return sale;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
