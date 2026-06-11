import 'package:flutter/material.dart';
import '../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  AuthProvider(this._api);

  bool _isAuthenticated = false;
  bool _loading = false;
  String? _error;
  String? _username;
  int? _userId;

  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;
  String? get error => _error;
  String? get username => _username;
  int? get userId => _userId;

  Future<void> checkAuth() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final authenticated = await _api.isAuthenticated();
      if (authenticated) {
        try {
          final me = await _api.getMe();
          _userId = me['userId'] as int?;
          _username = me['username'] as String?;
          _isAuthenticated = true;
        } catch (e) {
          _isAuthenticated = false;
          _username = null;
          _userId = null;
        }
      } else {
        _isAuthenticated = false;
        _username = null;
        _userId = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _username = null;
      _userId = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.login(username, password);
      final user = response['user'] as Map<String, dynamic>?;
      _userId = user?['userId'] as int?;
      _username = user?['username'] as String?;
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.register(username, password);
      final user = response['user'] as Map<String, dynamic>?;
      _userId = user?['userId'] as int?;
      _username = user?['username'] as String?;
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _isAuthenticated = false;
    _username = null;
    _userId = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
