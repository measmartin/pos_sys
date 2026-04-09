import 'package:flutter/material.dart';
import '../data/models/unit_model.dart';
import '../data/services/api_service.dart';

class UnitProvider extends ChangeNotifier {
  final ApiService _api;
  UnitProvider(this._api);

  List<UnitDetailsDto> _units = [];
  bool _loading = false;
  String? _error;
  String _search = '';

  List<UnitDetailsDto> get units => _units;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;

  List<UnitDetailsDto> get filtered {
    if (_search.isEmpty) return _units;
    final q = _search.toLowerCase();
    return _units
        .where(
          (u) =>
              (u.unitName.toLowerCase().contains(q)) ||
              (u.unitCode.toLowerCase().contains(q)) ||
              (u.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  Future<void> loadUnits() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _api.getUnits();
      _units = raw
          .map((e) => UnitDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createUnit(Map<String, dynamic> dto) async {
    try {
      final id = await _api.createUnit(dto);
      final newUnitRaw = await _api.getUnit(id);
      final newUnit = UnitDetailsDto.fromJson(newUnitRaw);
      _units.add(newUnit);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUnit(int id, Map<String, dynamic> dto) async {
    try {
      await _api.updateUnit(id, dto);
      final updatedUnitRaw = await _api.getUnit(id);
      final updatedUnit = UnitDetailsDto.fromJson(updatedUnitRaw);
      final index = _units.indexWhere((u) => u.unitId == id);
      if (index != -1) {
        _units[index] = updatedUnit;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUnit(int id) async {
    try {
      await _api.deleteUnit(id);
      _units.removeWhere((u) => u.unitId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
