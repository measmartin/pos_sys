import 'package:flutter/material.dart';
import '../data/models/category_model.dart'; // Import the correct model
import '../data/services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _api;
  CategoryProvider(this._api);

  List<CategoryDetailsDto> _categories = [];
  bool _loading = false;
  String? _error;
  String _search = '';

  List<CategoryDetailsDto> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;

  List<CategoryDetailsDto> get filtered {
    if (_search.isEmpty) return _categories;
    final q = _search.toLowerCase();
    return _categories
        .where((c) =>
            (c.categoryName.toLowerCase().contains(q)) ||
            (c.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _api.getCategories();
      _categories = raw
          .map((e) => CategoryDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(Map<String, dynamic> dto) async {
    try {
      final id = await _api.createCategory(dto);
      final newCategoryRaw = await _api.getCategory(id); // Fetch the newly created category
      final newCategory = CategoryDetailsDto.fromJson(newCategoryRaw);
      _categories.add(newCategory); // Add to local list
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> dto) async {
    try {
      await _api.updateCategory(id, dto);
      final updatedCategoryRaw = await _api.getCategory(id); // Fetch the updated category
      final updatedCategory = CategoryDetailsDto.fromJson(updatedCategoryRaw);
      final index = _categories.indexWhere((c) => c.categoryId == id);
      if (index != -1) {
        _categories[index] = updatedCategory; // Update in local list
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _api.deleteCategory(id);
      _categories.removeWhere((c) => c.categoryId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
