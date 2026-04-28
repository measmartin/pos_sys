import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/currency_model.dart';
import '../data/models/sales_model.dart';
import '../data/services/api_service.dart';

enum DashboardCurrencyView { usd, khr, both }

class DashboardProvider extends ChangeNotifier {
  final ApiService _api;
  DashboardProvider(this._api);

  List<SalesDetailsDto> _sales = [];
  List<CurrencyDetailsDto> _currencies = [];
  bool _loading = false;
  String? _error;
  DashboardCurrencyView _currencyView = DashboardCurrencyView.usd;

  List<SalesDetailsDto> get sales => _sales;
  DashboardCurrencyView get currencyView => _currencyView;
  bool get loading => _loading;
  String? get error => _error;

  String get activeCurrencySymbol {
    switch (_currencyView) {
      case DashboardCurrencyView.usd:
        final usd = _findByCode('USD');
        return usd?.currencySymbol ?? usd?.currencyCode ?? r'$';
      case DashboardCurrencyView.khr:
        final khr = _findByCode('KHR');
        return khr?.currencySymbol ?? khr?.currencyCode ?? 'KHR';
      case DashboardCurrencyView.both:
        return _baseCurrency?.currencySymbol ?? _baseCurrency?.currencyCode ?? r'$';
    }
  }

  String get activeCurrencyLabel {
    switch (_currencyView) {
      case DashboardCurrencyView.usd:
        return 'USD';
      case DashboardCurrencyView.khr:
        return 'KHR';
      case DashboardCurrencyView.both:
        return '${_baseCurrency?.currencyCode ?? 'USD'}';
    }
  }

  String? get bothRateLabel {
    final usd = _findByCode('USD');
    final khr = _findByCode('KHR');
    if (usd == null || khr == null) return null;
    if (usd.exchangeRate == 0) return null;

    final khrPerUsd = khr.exchangeRate / usd.exchangeRate;
    final formatter = (khrPerUsd - khrPerUsd.roundToDouble()).abs() < 0.00001
        ? NumberFormat.decimalPattern()
        : NumberFormat.decimalPatternDigits(decimalDigits: 2);
    return '1 USD = ${formatter.format(khrPerUsd)} KHR';
  }

  double get totalSalesToday {
    final today = DateTime.now();
    return _filteredSalesForView()
        .where((s) => _isSameDate(s.saleDate, today))
        .fold(0.0, (sum, s) => sum + _displayAmountForView(s));
  }

  int get transactionCount {
    final today = DateTime.now();
    return _filteredSalesForView().where((s) => _isSameDate(s.saleDate, today)).length;
  }

  double get avgOrderValue {
    final count = transactionCount;
    if (count == 0) return 0;
    return totalSalesToday / count;
  }

  List<Map<String, dynamic>> get weeklyData {
    final now = DateTime.now();
    final mon = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );
    final items = _filteredSalesForView();
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return List.generate(7, (i) {
      final day = mon.add(Duration(days: i));
      final amount = items
          .where((s) => _isSameDate(s.saleDate, day))
          .fold(0.0, (sum, s) => sum + _displayAmountForView(s));
      return {'day': labels[i], 'amount': amount};
    });
  }

  List<SalesDetailsDto> get recentSales {
    final items = _filteredSalesForView().toList()
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));
    return items;
  }

  void setCurrencyView(DashboardCurrencyView view) {
    if (_currencyView == view) return;
    _currencyView = view;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final responses = await Future.wait([
        _api.getSales(pageSize: 500),
        _api.getCurrencies(),
      ]);
      final rawSales = responses[0] as List<dynamic>;
      final rawCurrencies = responses[1] as List<dynamic>;
      _sales = rawSales
          .map((e) => SalesDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
      _currencies = rawCurrencies
          .map((e) => CurrencyDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  CurrencyDetailsDto? get _baseCurrency {
    if (_currencies.isEmpty) return null;
    return _currencies.firstWhere(
      (c) => c.isBaseCurrency,
      orElse: () => _findByCode('USD') ?? _currencies.first,
    );
  }

  CurrencyDetailsDto? _findByCode(String code) {
    for (final c in _currencies) {
      if (c.currencyCode.toUpperCase() == code.toUpperCase()) return c;
    }
    return null;
  }

  List<SalesDetailsDto> _filteredSalesForView() {
    switch (_currencyView) {
      case DashboardCurrencyView.usd:
        final usd = _findByCode('USD');
        return _sales.where((s) {
          if ((s.currencyCode ?? '').toUpperCase() == 'USD') return true;
          return usd != null && s.currencyId == usd.currencyId;
        }).toList();
      case DashboardCurrencyView.khr:
        final khr = _findByCode('KHR');
        return _sales.where((s) {
          if ((s.currencyCode ?? '').toUpperCase() == 'KHR') return true;
          return khr != null && s.currencyId == khr.currencyId;
        }).toList();
      case DashboardCurrencyView.both:
        return _sales;
    }
  }

  double _displayAmountForView(SalesDetailsDto sale) {
    if (_currencyView != DashboardCurrencyView.both) {
      return sale.totalAmount;
    }
    return _convertSaleToBase(sale);
  }

  double _convertSaleToBase(SalesDetailsDto sale) {
    final base = _baseCurrency;
    if (base == null) return sale.totalAmount;
    if (sale.currencyId == base.currencyId) return sale.totalAmount;
    final saleCurrency = _currencies.where((c) => c.currencyId == sale.currencyId);
    final rate = saleCurrency.isNotEmpty ? saleCurrency.first.exchangeRate : 1.0;
    if (rate == 0) return sale.totalAmount;
    return sale.totalAmount / rate;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
