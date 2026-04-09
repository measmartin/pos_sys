import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'providers/connection_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/category_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/currency_provider.dart';
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

class AmritPosApp extends StatelessWidget {
  const AmritPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionProvider = ConnectionProvider();
    final baseUrl = _resolveApiBaseUrl();
    final apiKey = 'dev-api-key-12345';

    final api = ApiService(
      baseUrl: baseUrl,
      apiKey: apiKey,
      onApiError: (error) => connectionProvider.recordError(error),
      onApiSuccess: () => connectionProvider.recordSuccess(),
      debugLogging: false,
    );

    connectionProvider.initialize(baseUrl: baseUrl, apiKey: apiKey);

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<ConnectionProvider>.value(
          value: connectionProvider,
        ),
        ChangeNotifierProvider(create: (_) => DashboardProvider(api)),
        ChangeNotifierProvider(create: (_) => ProductProvider(api)),
        ChangeNotifierProvider(create: (_) => SalesProvider(api)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(api)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(api)),
        ChangeNotifierProvider(create: (_) => UnitProvider(api)),
        ChangeNotifierProvider(create: (_) => CurrencyProvider(api)),
      ],
      child: MaterialApp(
        title: 'Amrit POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}
