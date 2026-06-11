import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StoreConfig {
  final String name;
  final String address;
  final String phone;

  const StoreConfig({
    this.name = 'Amrit POS',
    this.address = '',
    this.phone = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
      };

  factory StoreConfig.fromJson(Map<String, dynamic> json) => StoreConfig(
        name: json['name'] as String? ?? 'Amrit POS',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );

  StoreConfig copyWith({String? name, String? address, String? phone}) =>
      StoreConfig(
        name: name ?? this.name,
        address: address ?? this.address,
        phone: phone ?? this.phone,
      );
}

enum PrinterType { usb, network }

class PrinterConfig {
  final PrinterType type;
  final String address;
  final int port;
  final String displayName;
  final bool isDefault;

  const PrinterConfig({
    required this.type,
    required this.address,
    this.port = 9100,
    required this.displayName,
    this.isDefault = true,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'address': address,
        'port': port,
        'displayName': displayName,
        'isDefault': isDefault,
      };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) => PrinterConfig(
        type: PrinterConfig._typeFromString(json['type'] as String? ?? 'network'),
        address: json['address'] as String? ?? '',
        port: json['port'] as int? ?? 9100,
        displayName: json['displayName'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? true,
      );

  static PrinterType _typeFromString(String s) {
    if (s == 'usb') return PrinterType.usb;
    return PrinterType.network;
  }
}

class PrinterSettings {
  static const _printerKey = 'printer_config';
  static const _storeKey = 'store_config';
  static const _autoPrintKey = 'auto_print';

  static Future<void> savePrinter(PrinterConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerKey, jsonEncode(config.toJson()));
  }

  static Future<PrinterConfig?> loadPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_printerKey);
    if (str == null) return null;
    return PrinterConfig.fromJson(jsonDecode(str));
  }

  static Future<void> saveStore(StoreConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKey, jsonEncode(config.toJson()));
  }

  static Future<StoreConfig> loadStore() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_storeKey);
    if (str == null) return const StoreConfig();
    return StoreConfig.fromJson(jsonDecode(str));
  }

  static Future<void> setAutoPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPrintKey, value);
  }

  static Future<bool> autoPrintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPrintKey) ?? true;
  }
}