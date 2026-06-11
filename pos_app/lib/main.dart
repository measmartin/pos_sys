import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/printing/printer_provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/connection_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/category_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/report_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/app_shell.dart';

void main() {
  runApp(const AmritPosApp());
}

String _resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) {
    return 'http://localhost:5010';
  }

  if (Platform.isAndroid) {
    // Android emulator maps host localhost to 10.0.2.2.
    return 'http://10.0.2.2:5010';
  }

  if (Platform.isIOS) {
    // iOS simulator can usually reach host machine via localhost.
    return 'http://localhost:5010';
  }

  return 'http://localhost:5010';
}

class AmritPosApp extends StatefulWidget {
  const AmritPosApp({super.key});

  @override
  State<AmritPosApp> createState() => _AmritPosAppState();
}

class _AmritPosAppState extends State<AmritPosApp> {
  late final ConnectionProvider _connectionProvider;
  late final ApiService _api;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    final baseUrl = _resolveApiBaseUrl();
    const apiKeyFromEnv = String.fromEnvironment('API_KEY');
    final apiKey = apiKeyFromEnv.isNotEmpty ? apiKeyFromEnv : null;

    _connectionProvider = ConnectionProvider();
    _api = ApiService(
      baseUrl: baseUrl,
      apiKey: apiKey,
      onApiError: (error) => _connectionProvider.recordError(error),
      onApiSuccess: () => _connectionProvider.recordSuccess(),
      debugLogging: false,
    );

    _connectionProvider.initialize(baseUrl: baseUrl, apiKey: apiKey);
    _authProvider = AuthProvider(_api);

    _api.authExpired.addListener(_onAuthExpired);
  }

  void _onAuthExpired() {
    if (_api.authExpired.value) {
      _api.authExpired.value = false;
      _authProvider.logout();
    }
  }

  @override
  void dispose() {
    _api.authExpired.removeListener(_onAuthExpired);
    _api.dispose();
    _connectionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: _api),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ConnectionProvider>.value(
          value: _connectionProvider,
        ),
        ChangeNotifierProvider(create: (_) => DashboardProvider(_api)),
        ChangeNotifierProvider(create: (_) => ProductProvider(_api)),
        ChangeNotifierProvider(create: (_) => SalesProvider(_api)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(_api)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(_api)),
        ChangeNotifierProvider(create: (_) => UnitProvider(_api)),
        ChangeNotifierProvider(create: (_) => CurrencyProvider(_api)),
        ChangeNotifierProvider(create: (_) => ReportProvider(_api)),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
      ],
      child: MaterialApp(
        title: 'Amrit POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: AuthGate(authProvider: _authProvider),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  final AuthProvider authProvider;
  const AuthGate({super.key, required this.authProvider});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await widget.authProvider.checkAuth();
    if (mounted) {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final auth = context.watch<AuthProvider>();
    return auth.isAuthenticated ? const AppShell() : const LoginScreen();
  }
}
