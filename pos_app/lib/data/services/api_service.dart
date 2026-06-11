import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

typedef OnApiError = void Function(String error);
typedef OnApiSuccess = void Function();

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String _defaultBaseUrl = 'http://localhost:5010';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final String baseUrl;
  final String? apiKey;
  final http.Client _client;
  final OnApiError? onApiError;
  final OnApiSuccess? onApiSuccess;
  final bool debugLogging;
  String? _authToken;
  String? _refreshToken;
  final ValueNotifier<bool> authExpired = ValueNotifier(false);
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  ApiService({
    String? baseUrl,
    this.apiKey,
    http.Client? client,
    this.onApiError,
    this.onApiSuccess,
    this.debugLogging = true,
  }) : baseUrl = baseUrl ?? _defaultBaseUrl,
       _client = client ?? http.Client();

  void _log(String message) {
    if (debugLogging) {
      debugPrint('[ApiService] $message');
    }
  }

  Future<String?> get authToken async {
    if (_authToken != null) return _authToken;
    _authToken = await _secureStorage.read(key: _tokenKey);
    return _authToken;
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> get refreshToken async {
    if (_refreshToken != null) return _refreshToken;
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  Future<void> setRefreshToken(String token) async {
    _refreshToken = token;
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    _refreshToken = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> _performRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshWaiters.add(completer);
      await completer.future;
      final token = await authToken;
      return token != null && token.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final refreshed = await tryRefreshToken();
      for (final waiter in _refreshWaiters) {
        waiter.complete();
      }
      _refreshWaiters.clear();
      return refreshed;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await authToken;
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> get _headers async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await authToken;
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    } else if (apiKey != null && apiKey!.isNotEmpty) {
      h['X-API-Key'] = apiKey!;
    }
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  List<dynamic> _extractListResponse(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List<dynamic>) return payload;
    }
    return const [];
  }

  Future<dynamic> _handleResponse(
    http.Response res, {
    String method = 'REQUEST',
    String path = '',
  }) async {
    final reqMethod = res.request?.method ?? method;
    final reqUri = res.request?.url;
    final reqPath = reqUri == null
        ? path
        : '${reqUri.path}${reqUri.hasQuery ? '?${reqUri.query}' : ''}';

    try {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        _log('$reqMethod $reqPath → ${res.statusCode} OK');
        onApiSuccess?.call();
        if (res.body.isEmpty) return null;
        return jsonDecode(res.body);
      }

      String msg = res.body;
      try {
        final body = jsonDecode(res.body);
        msg = body['message'] ?? body['title'] ?? msg;
      } catch (e) {
        _log('Failed to parse error response body: $e');
      }

      if (res.statusCode == 401) {
        final refreshed = await _performRefresh();
        if (!refreshed) {
          await clearAuthToken();
          authExpired.value = true;
        }
      }

      final bodyPreview = res.body.length > 600
          ? '${res.body.substring(0, 600)}...'
          : res.body;
      final error =
          '$reqMethod $reqPath -> HTTP ${res.statusCode}\nMessage: $msg\nResponse: $bodyPreview';
      _log('$reqMethod $reqPath → ${res.statusCode} ERROR: $msg');
      onApiError?.call(error);
      throw ApiException(res.statusCode, msg);
    } catch (e) {
      if (e is ApiException) rethrow;
      final errorMsg = '$reqMethod $reqPath -> EXCEPTION: $e';
      _log(errorMsg);
      onApiError?.call(errorMsg);
      rethrow;
    }
  }

  // --- Products ---
  Future<List<dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    int? categoryId,
    bool? isActive,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'categoryId': '$categoryId',
      if (isActive != null) 'isActive': '$isActive',
    };
    const path = '/api/products';
    _log('GET $path (page: $page)');
    try {
      final res = await _client
          .get(_uri(path, query), headers: await _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('GET $path timed out after 10s'),
          );
      final data = await _handleResponse(res, method: 'GET', path: path);
      return _extractListResponse(data);
    } on TimeoutException catch (e) {
      final errorMsg = e.toString();
      _log('GET $path → TIMEOUT: $errorMsg');
      onApiError?.call(errorMsg);
      rethrow;
    } catch (e) {
      final errorMsg = 'GET $path -> EXCEPTION: $e';
      _log(errorMsg);
      onApiError?.call(errorMsg);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final res = await _client.get(_uri('/api/products/$id'), headers: await _headers);
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/products'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    final body = await _handleResponse(res);
    if (body is Map<String, dynamic>) return body;
    if (body is int) return {'id': body};
    if (body is String) {
      final parsed = int.tryParse(body);
      if (parsed != null) return {'id': parsed};
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> dto,
  ) async {
    final res = await _client.put(
      _uri('/api/products/$id'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    final response = await _handleResponse(res);
    return response is Map<String, dynamic> ? response : {};
  }

  Future<void> deleteProduct(int id) async {
    final res = await _client.delete(
      _uri('/api/products/$id'),
      headers: await _headers,
    );
    await _handleResponse(res);
  }

  // --- Product Units ---
  Future<List<dynamic>> getProductUnits(int productId) async {
    final query = <String, String>{
      'productId': '$productId',
    };
    const path = '/api/productunits';
    _log('GET $path?productId=$productId');
    try {
      final res = await _client
          .get(_uri(path, query), headers: await _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('GET $path timed out after 10s'),
          );
      final data = await _handleResponse(res, method: 'GET', path: path);
      return _extractListResponse(data);
    } on TimeoutException catch (e) {
      final errorMsg = e.toString();
      _log('GET $path -> TIMEOUT: $errorMsg');
      onApiError?.call(errorMsg);
      rethrow;
    } catch (e) {
      final errorMsg = 'GET $path -> EXCEPTION: $e';
      _log(errorMsg);
      onApiError?.call(errorMsg);
      rethrow;
    }
  }

  Future<String?> getProductImageUrl(int productUnitId) async {
    return '$baseUrl/api/productunits/$productUnitId/image';
  }

  Future<Map<String, dynamic>> uploadProductUnitImage(
    int productUnitId,
    List<int> fileBytes,
    String filename,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/productunits/$productUnitId/image'),
    );
    final token = await authToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = await _handleResponse(res);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<void> deleteProductUnitImage(int productUnitId) async {
    final res = await _client.delete(
      _uri('/api/productunits/$productUnitId/image'),
      headers: await _headers,
    );
    await _handleResponse(res);
  }

  Future<int> createProductUnit(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/productunits'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    final body = await _handleResponse(res);
    if (body is int) return body;
    if (body is Map<String, dynamic>) {
      final id = body['id'] as int?;
      if (id != null) return id;
    }
    throw Exception('Failed to create product unit: invalid response format');
  }

  Future<Map<String, dynamic>> updateProductUnit(
    int id,
    Map<String, dynamic> dto,
  ) async {
    final res = await _client.put(
      _uri('/api/productunits/$id'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    final response = await _handleResponse(res);
    return response is Map<String, dynamic> ? response : {};
  }

  Future<void> deleteProductUnit(int id) async {
    final res = await _client.delete(
      _uri('/api/productunits/$id'),
      headers: await _headers,
    );
    await _handleResponse(res);
  }

  // --- Sales ---
  Future<List<dynamic>> getSales({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final res = await _client.get(_uri('/api/sales', query), headers: await _headers);
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
    final res = await _client.get(
      _uri('/api/sales/date-range', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<Map<String, dynamic>> getSale(int id) async {
    final res = await _client.get(_uri('/api/sales/$id'), headers: await _headers);
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/sales'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    final body = await _handleResponse(res);

    // Some endpoints return just the created ID. Normalize to full sale details.
    if (body is int) {
      return await getSale(body);
    }

    if (body is String) {
      final parsed = int.tryParse(body);
      if (parsed != null) {
        return await getSale(parsed);
      }
    }

    if (body is Map<String, dynamic>) {
      if (body.containsKey('saleId')) {
        return body;
      }

      final rawId = body['id'];
      if (rawId is int) {
        return await getSale(rawId);
      }

      if (rawId is String) {
        final parsed = int.tryParse(rawId);
        if (parsed != null) {
          return await getSale(parsed);
        }
      }
    }

    throw ApiException(
      res.statusCode,
      'Unexpected create sale response type: ${body.runtimeType}',
    );
  }

  Future<void> processSalePayment(int saleId, Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/sales/$saleId/payment'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    await _handleResponse(res);
  }

  Future<void> voidSale(int saleId) async {
    final res = await _client.post(
      _uri('/api/sales/$saleId/void'),
      headers: await _headers,
    );
    await _handleResponse(res);
  }

  // --- Customers ---
  Future<List<dynamic>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _client.get(
      _uri('/api/customers', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<Map<String, dynamic>> getCustomer(int id) async {
    final res = await _client.get(
      _uri('/api/customers/$id'),
      headers: await _headers,
    );
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/customers'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCustomer(
    int id,
    Map<String, dynamic> dto,
  ) async {
    final res = await _client.put(
      _uri('/api/customers/$id'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    final response = await _handleResponse(res);
    return response is Map<String, dynamic> ? response : {};
  }

  // --- Categories ---
  Future<List<dynamic>> getCategories({
    int page = 1,
    int pageSize = 50,
    String? search,
    bool? isActive,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': '$isActive',
    };
    const path = '/api/categories';
    _log('GET $path (page: $page)');
    try {
      final res = await _client
          .get(_uri(path, query), headers: await _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('GET $path timed out after 10s'),
          );
      final data = await _handleResponse(res, method: 'GET', path: path);
      return _extractListResponse(data);
    } on TimeoutException catch (e) {
      final errorMsg = e.toString();
      _log('GET $path -> TIMEOUT: $errorMsg');
      onApiError?.call(errorMsg);
      rethrow;
    } catch (e) {
      final errorMsg = 'GET $path -> EXCEPTION: $e';
      _log(errorMsg);
      onApiError?.call(errorMsg);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategory(int id) async {
    final res = await _client.get(
      _uri('/api/categories/$id'),
      headers: await _headers,
    );
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<int> createCategory(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/categories'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    return await _handleResponse(res) as int;
  }

  Future<void> updateCategory(int id, Map<String, dynamic> dto) async {
    final res = await _client.put(
      _uri('/api/categories/$id'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    await _handleResponse(res);
  }

  Future<void> deleteCategory(int id) async {
    final res = await _client.delete(
      _uri('/api/categories/$id'),
      headers: await _headers,
    );
    await _handleResponse(res);
  }

  // --- Units ---
  Future<List<dynamic>> getUnits({
    int page = 1,
    int pageSize = 50,
    String? search,
    bool? isActive,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': '$isActive',
    };
    const path = '/api/units';
    _log('GET $path (page: $page)');
    try {
      final res = await _client
          .get(_uri(path, query), headers: await _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('GET $path timed out after 10s'),
          );
      final data = await _handleResponse(res, method: 'GET', path: path);
      return _extractListResponse(data);
    } on TimeoutException catch (e) {
      final errorMsg = e.toString();
      _log('GET $path -> TIMEOUT: $errorMsg');
      onApiError?.call(errorMsg);
      rethrow;
    } catch (e) {
      final errorMsg = 'GET $path -> EXCEPTION: $e';
      _log(errorMsg);
      onApiError?.call(errorMsg);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUnit(int id) async {
    final res = await _client.get(_uri('/api/units/$id'), headers: await _headers);
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<int> createUnit(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/units'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    return await _handleResponse(res) as int;
  }

  Future<void> updateUnit(int id, Map<String, dynamic> dto) async {
    final res = await _client.put(
      _uri('/api/units/$id'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    await _handleResponse(res);
  }

  Future<void> deleteUnit(int id) async {
    final res = await _client.delete(_uri('/api/units/$id'), headers: await _headers);
    await _handleResponse(res);
  }

  // --- Currencies ---
  Future<List<dynamic>> getCurrencies({
    int page = 1,
    int pageSize = 50,
    String? search,
    bool? isActive,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': '$isActive',
    };
    const path = '/api/currencies';
    _log('GET $path (page: $page)');
    try {
      final res = await _client
          .get(_uri(path, query), headers: await _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('GET $path timed out after 10s'),
          );
      final data = await _handleResponse(res, method: 'GET', path: path);
      return _extractListResponse(data);
    } on TimeoutException catch (e) {
      final errorMsg = e.toString();
      _log('GET $path -> TIMEOUT: $errorMsg');
      onApiError?.call(errorMsg);
      rethrow;
    } catch (e) {
      final errorMsg = 'GET $path -> EXCEPTION: $e';
      _log(errorMsg);
      onApiError?.call(errorMsg);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrency(int id) async {
    final res = await _client.get(
      _uri('/api/currencies/$id'),
      headers: await _headers,
    );
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<int> createCurrency(Map<String, dynamic> dto) async {
    final res = await _client.post(
      _uri('/api/currencies'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    return await _handleResponse(res) as int;
  }

  Future<void> updateCurrency(int id, Map<String, dynamic> dto) async {
    final res = await _client.put(
      _uri('/api/currencies/$id'),
      headers: await _headers,
      body: jsonEncode(dto),
    );
    await _handleResponse(res);
  }

  Future<void> deleteCurrency(int id) async {
    final res = await _client.delete(
      _uri('/api/currencies/$id'),
      headers: await _headers,
    );
    await _handleResponse(res);
  }

  // --- Reports ---
  Future<Map<String, dynamic>> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/sales/summary', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<List<dynamic>> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/sales/daily', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getTopProducts({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
    int topN = 20,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'topN': '$topN',
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/products/top', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getCategorySales({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/products/category', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getTopCustomers({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
    int topN = 20,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'topN': '$topN',
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/customers/top', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getPaymentBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/payments/breakdown', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getSalesForExport({
    required DateTime startDate,
    required DateTime endDate,
    int? currencyId,
  }) async {
    final query = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (currencyId != null) 'currencyId': '$currencyId',
    };
    final res = await _client.get(
      _uri('/api/reports/sales/export', query),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  Future<List<dynamic>> getReportCurrencies() async {
    final res = await _client.get(
      _uri('/api/reports/currencies'),
      headers: await _headers,
    );
    final data = await _handleResponse(res);
    return _extractListResponse(data);
  }

  // --- Dashboard Stats ---
  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await _client.get(
      _uri('/api/dashboard/stats'),
      headers: await _headers,
    );
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  // --- Diagnostics ---
  Future<Map<String, dynamic>> getConnectionDiagnostics() async {
    const path = '/api/diagnostics/connection';
    _log('GET $path');
    final res = await _client
        .get(_uri(path), headers: await _headers)
        .timeout(const Duration(seconds: 5));
    final data = await _handleResponse(res, method: 'GET', path: path);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// Test connectivity to the API server
  Future<bool> healthCheck() async {
    try {
      final diagnostics = await getConnectionDiagnostics();
      final ok = diagnostics['ok'] == true;
      if (ok) {
        _log('Health check: OK');
        onApiSuccess?.call();
        return true;
      }

      final error = diagnostics['message']?.toString() ?? 'Health check failed';
      _log('Health check: $error');
      onApiError?.call(error);
      return false;
    } on TimeoutException {
      final error = 'Health check timeout (5s)';
      _log('Health check: $error');
      onApiError?.call(error);
      return false;
    } catch (e) {
      final error = 'Health check error: $e';
      _log('Health check: $error');
      onApiError?.call(error);
      return false;
    }
  }

  // --- Auth ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _client.post(
      _uri('/api/auth/login'),
      headers: await _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = await _handleResponse(res);
    if (body is Map<String, dynamic>) {
      final token = body['token'] as String?;
      final refreshToken = body['refreshToken'] as String?;
      if (token != null) {
        await setAuthToken(token);
      }
      if (refreshToken != null) {
        await setRefreshToken(refreshToken);
      }
      return body;
    }
    throw ApiException(res.statusCode, 'Invalid login response');
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    final res = await _client.post(
      _uri('/api/auth/register'),
      headers: await _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = await _handleResponse(res);
    if (body is Map<String, dynamic>) {
      final token = body['token'] as String?;
      final refreshToken = body['refreshToken'] as String?;
      if (token != null) {
        await setAuthToken(token);
      }
      if (refreshToken != null) {
        await setRefreshToken(refreshToken);
      }
      return body;
    }
    throw ApiException(res.statusCode, 'Invalid register response');
  }

  Future<bool> tryRefreshToken() async {
    final rt = await refreshToken;
    if (rt == null) return false;
    try {
      final res = await _client.post(
        _uri('/api/auth/refresh'),
        headers: await _headers,
        body: jsonEncode({'refreshToken': rt}),
      );
      final body = await _handleResponse(res);
      if (body is Map<String, dynamic>) {
        final token = body['token'] as String?;
        final newRefreshToken = body['refreshToken'] as String?;
        if (token != null) {
          await setAuthToken(token);
        }
        if (newRefreshToken != null) {
          await setRefreshToken(newRefreshToken);
        }
        return true;
      }
    } catch (e) {
      _log('Refresh token failed: $e');
      await clearAuthToken();
      authExpired.value = true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _client.get(
      _uri('/api/auth/me'),
      headers: await _headers,
    );
    return await _handleResponse(res) as Map<String, dynamic>;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final res = await _client.post(
      _uri('/api/auth/change-password'),
      headers: await _headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    await _handleResponse(res);
  }

  Future<void> logout() async {
    await clearAuthToken();
  }

  void dispose() {
    _client.close();
  }
}
