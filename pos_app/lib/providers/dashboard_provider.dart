import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api;
  DashboardProvider(this._api);

  Map<String, dynamic>? _stats;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;

  double get totalSalesToday => (_stats?['totalSalesToday'] as num?)?.toDouble() ?? 0;
  int get transactionCount => (_stats?['transactionCount'] as num?)?.toInt() ?? 0;
  double get avgOrderValue => (_stats?['avgOrderValue'] as num?)?.toDouble() ?? 0;
  List<dynamic> get weeklyData => _stats?['weeklyData'] as List<dynamic>? ?? _mockWeekly;
  List<dynamic> get recentSales => _stats?['recentSales'] as List<dynamic>? ?? [];

  // Mock weekly data when API not available
  final List<Map<String, dynamic>> _mockWeekly = [
    {'day': 'MON', 'amount': 4500.0},
    {'day': 'TUE', 'amount': 8200.0},
    {'day': 'WED', 'amount': 6100.0},
    {'day': 'THU', 'amount': 11400.0},
    {'day': 'FRI', 'amount': 9300.0},
    {'day': 'SAT', 'amount': 13800.0},
    {'day': 'SUN', 'amount': 12482.5},
  ];

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _api.getDashboardStats();
    } catch (_) {
      // Use mock data if API unavailable
      _stats = {
        'totalSalesToday': 12482.50,
        'transactionCount': 142,
        'avgOrderValue': 87.90,
        'weeklyData': _mockWeekly,
        'recentSales': [],
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
