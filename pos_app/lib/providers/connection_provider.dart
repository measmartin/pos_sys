import 'package:flutter/foundation.dart';

class ConnectionProvider extends ChangeNotifier {
  String _baseUrl = '';
  String _apiKey = '';
  bool _isConnected = false;
  String? _lastError;
  DateTime? _lastErrorTime;
  DateTime? _lastSuccessTime;
  int _requestCount = 0;
  int _errorCount = 0;

  // Getters
  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;
  DateTime? get lastErrorTime => _lastErrorTime;
  DateTime? get lastSuccessTime => _lastSuccessTime;
  int get requestCount => _requestCount;
  int get errorCount => _errorCount;

  void initialize({required String baseUrl, String? apiKey}) {
    _baseUrl = baseUrl;
    _apiKey = apiKey ?? '';
    notifyListeners();
  }

  void recordRequest() {
    _requestCount++;
    notifyListeners();
  }

  void recordSuccess() {
    _isConnected = true;
    _lastSuccessTime = DateTime.now();
    _lastError = null;
    notifyListeners();
  }

  void recordError(String error) {
    _isConnected = false;
    _lastError = error;
    _lastErrorTime = DateTime.now();
    _errorCount++;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  String get statusText {
    if (!_isConnected && _lastError != null) {
      return '❌ Offline: $_lastError';
    }
    if (_isConnected) {
      final ago = DateTime.now().difference(_lastSuccessTime!);
      final agoText = ago.inSeconds < 60
          ? '${ago.inSeconds}s ago'
          : ago.inMinutes < 60
              ? '${ago.inMinutes}m ago'
              : '${ago.inHours}h ago';
      return '🟢 Online (last: $agoText)';
    }
    return '🟡 Untested';
  }

  String get debugInfo {
    final buf = StringBuffer();
    buf.writeln('=== API Connection Debug ===');
    buf.writeln('Base URL: $_baseUrl');
    buf.writeln('Status: $statusText');
    buf.writeln('Requests: $_requestCount | Errors: $_errorCount');
    if (_lastError != null) {
      buf.writeln('Last Error: $_lastError');
      buf.writeln('Error Time: ${_lastErrorTime?.toIso8601String()}');
    }
    if (_lastSuccessTime != null) {
      buf.writeln('Last Success: ${_lastSuccessTime?.toIso8601String()}');
    }
    return buf.toString();
  }
}
