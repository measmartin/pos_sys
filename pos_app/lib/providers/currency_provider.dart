import 'package:flutter/material.dart';
import '../data/models/currency_model.dart';
import '../data/services/api_service.dart';

class CurrencyProvider extends ChangeNotifier {
  final ApiService _api;
  CurrencyProvider(this._api);

  List<CurrencyDetailsDto> _currencies = [];
  bool _loading = false;
  String? _error;
  String _search = '';

  List<CurrencyDetailsDto> get currencies => _currencies;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;

  List<CurrencyDetailsDto> get filtered {
    if (_search.isEmpty) return _currencies;
    final q = _search.toLowerCase();
    return _currencies
        .where(
          (c) =>
              (c.currencyName.toLowerCase().contains(q)) ||
              (c.currencyCode.toLowerCase().contains(q)) ||
              (c.currencySymbol?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  Future<void> loadCurrencies() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _api.getCurrencies();
      _currencies = raw
          .map((e) => CurrencyDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCurrency(Map<String, dynamic> dto) async {
    try {
      final id = await _api.createCurrency(dto);
      final newCurrencyRaw = await _api.getCurrency(id);
      final newCurrency = CurrencyDetailsDto.fromJson(newCurrencyRaw);
      _currencies.add(newCurrency);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCurrency(int id, Map<String, dynamic> dto) async {
    try {
      await _api.updateCurrency(id, dto);
      final updatedCurrencyRaw = await _api.getCurrency(id);
      final updatedCurrency = CurrencyDetailsDto.fromJson(updatedCurrencyRaw);
      final index = _currencies.indexWhere((c) => c.currencyId == id);
      if (index != -1) {
        _currencies[index] = updatedCurrency;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCurrency(int id) async {
    try {
      await _api.deleteCurrency(id);
      _currencies.removeWhere((c) => c.currencyId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
