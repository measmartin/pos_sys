import '../data/models/currency_model.dart';
import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/models/unit_model.dart';
import '../data/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api;
  ProductProvider(this._api);

  List<ProductDetailsDto> _products = [];
  List<CategoryDetailsDto> _categories = [];
  List<UnitDetailsDto> _units = [];
  List<CurrencyDetailsDto> _currencies = [];
  bool _loading = false;
  String? _error;
  String _search = '';
  int? _selectedCategoryId;

  List<ProductDetailsDto> get products => _products;
  List<CategoryDetailsDto> get categories => _categories;
  List<UnitDetailsDto> get units => _units;
  List<CurrencyDetailsDto> get currencies => _currencies;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;
  int? get selectedCategoryId => _selectedCategoryId;

  List<ProductDetailsDto> get filtered {
    var list = _products;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where(
            (p) =>
                p.productName.toLowerCase().contains(q) ||
                p.productCode.toLowerCase().contains(q) ||
                (p.categoryName?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    return list;
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void setCategory(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _api.getProducts(pageSize: 100);
      _products = raw
          .map((e) => ProductDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ProductDetailsDto?> getProductById(int id) async {
    try {
      final raw = await _api.getProduct(id);
      return ProductDetailsDto.fromJson(raw);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadCategories() async {
    try {
      final raw = await _api.getCategories();
      _categories = raw
          .map((e) => CategoryDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadUnits() async {
    try {
      final raw = await _api.getUnits();
      _units = raw
          .map((e) => UnitDetailsDto.fromJson(e as Map<String, dynamic>))
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
      notifyListeners();
    } catch (_) {}
  }

  Future<ProductDetailsDto?> createProduct(Map<String, dynamic> dto) async {
    try {
      final created = await _api.createProduct(dto);
      await loadProducts();

      final createdId = created['id'] as int?;
      if (createdId != null) {
        for (final p in _products) {
          if (p.productId == createdId) return p;
        }
      }

      final code = dto['productCode'] as String?;
      if (code != null && code.isNotEmpty) {
        final lowered = code.toLowerCase();
        for (final p in _products) {
          if (p.productCode.toLowerCase() == lowered) return p;
        }
      }

      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> uploadProductUnitImage(
    int productUnitId,
    List<int> fileBytes,
    String filename,
  ) async {
    try {
      await _api.uploadProductUnitImage(productUnitId, fileBytes, filename);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProductUnitImage(int productUnitId) async {
    try {
      await _api.deleteProductUnitImage(productUnitId);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<ProductDetailsDto?> updateProduct(
    int id,
    Map<String, dynamic> dto,
  ) async {
    try {
      await _api.updateProduct(id, dto);
      await loadProducts();
      for (final p in _products) {
        if (p.productId == id) return p;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _api.deleteProduct(id);
      _products.removeWhere((p) => p.productId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int?> createProductUnit(Map<String, dynamic> dto) async {
    try {
      final unitId = await _api.createProductUnit(dto);
      await loadProducts();
      return unitId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProductUnit(int id, Map<String, dynamic> dto) async {
    try {
      await _api.updateProductUnit(id, dto);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProductUnit(int id) async {
    try {
      await _api.deleteProductUnit(id);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
