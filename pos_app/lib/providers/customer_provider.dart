import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _api;
  CustomerProvider(this._api);

  List<CustomerDetailsDto> _customers = [];
  bool _loading = false;
  String? _error;
  String _search = '';

  List<CustomerDetailsDto> get customers => _customers;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;

  List<CustomerDetailsDto> get filtered {
    if (_search.isEmpty) return _customers;
    final q = _search.toLowerCase();
    return _customers
        .where((c) =>
            (c.customerName?.toLowerCase().contains(q) ?? false) ||
            (c.phoneNumber?.toLowerCase().contains(q) ?? false) ||
            (c.email?.toLowerCase().contains(q) ?? false) ||
            (c.city?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _api.getCustomers(pageSize: 100);
      _customers = raw
          .map((e) => CustomerDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> dto) async {
    try {
      final raw = await _api.createCustomer(dto);
      final customer = CustomerDetailsDto.fromJson(raw);
      _customers.insert(0, customer);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> dto) async {
    try {
      final raw = await _api.updateCustomer(id, dto);
      final updated = CustomerDetailsDto.fromJson(raw);
      final idx = _customers.indexWhere((c) => c.customerId == id);
      if (idx >= 0) _customers[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
