import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import '../../data/models/sales_model.dart';
import 'receipt_builder.dart';
import 'printer_settings.dart';

enum PrinterStatus { disconnected, connecting, connected, printing, error }

class PrinterProvider extends ChangeNotifier {
  PrinterStatus _status = PrinterStatus.disconnected;
  String? _error;
  PrinterConfig? _printerConfig;
  StoreConfig _storeConfig = const StoreConfig();
  bool _autoPrint = true;
  List<Printer> _discoveredPrinters = [];
  bool _scanning = false;

  PrinterStatus get status => _status;
  String? get error => _error;
  PrinterConfig? get printerConfig => _printerConfig;
  StoreConfig get storeConfig => _storeConfig;
  bool get autoPrint => _autoPrint;
  bool get isConfigured => _printerConfig != null;
  List<Printer> get discoveredPrinters => _discoveredPrinters;
  bool get scanning => _scanning;

  final FlutterThermalPrinter _ftp = FlutterThermalPrinter.instance;

  PrinterProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _printerConfig = await PrinterSettings.loadPrinter();
    _storeConfig = await PrinterSettings.loadStore();
    _autoPrint = await PrinterSettings.autoPrintEnabled();
    notifyListeners();
  }

  Future<void> scanPrinters() async {
    _scanning = true;
    _error = null;
    notifyListeners();

    try {
      await _ftp.stopScan();
      _discoveredPrinters.clear();

      _ftp.devicesStream.listen((printers) {
        _discoveredPrinters = List.of(printers);
        notifyListeners();
      });

      await _ftp.getPrinters(
        connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
      );

      await Future.delayed(const Duration(seconds: 5));
      await _ftp.stopScan();
    } catch (e) {
      _error = 'Scan failed: $e';
    }

    _scanning = false;
    notifyListeners();
  }

  Future<void> selectPrinter(PrinterConfig config) async {
    _printerConfig = config;
    await PrinterSettings.savePrinter(config);
    notifyListeners();
  }

  Future<void> updateStoreConfig(StoreConfig config) async {
    _storeConfig = config;
    await PrinterSettings.saveStore(config);
    notifyListeners();
  }

  Future<void> setAutoPrint(bool value) async {
    _autoPrint = value;
    await PrinterSettings.setAutoPrint(value);
    notifyListeners();
  }

  Printer? _buildPrinter() {
    if (_printerConfig == null) return null;
    return Printer(
      address: _printerConfig!.address,
      name: _printerConfig!.displayName,
      connectionType: _printerConfig!.type == PrinterType.usb
          ? ConnectionType.USB
          : ConnectionType.USB,
      isConnected: false,
    );
  }

  Future<bool> printReceipt(SalesDetailsDto sale) async {
    final printerObj = _buildPrinter();
    if (printerObj == null) {
      _error = 'No printer configured';
      _status = PrinterStatus.error;
      notifyListeners();
      return false;
    }

    _status = PrinterStatus.connecting;
    _error = null;
    notifyListeners();

    try {
      final connected = await _ftp.connect(printerObj);
      if (!connected) {
        _status = PrinterStatus.error;
        _error = 'Failed to connect to printer';
        notifyListeners();
        return false;
      }

      _status = PrinterStatus.printing;
      notifyListeners();

      final bytes = await ReceiptBuilder.build(sale, _storeConfig);
      await _ftp.printData(printerObj, bytes);

      _status = PrinterStatus.connected;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = PrinterStatus.error;
      _error = 'Print failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> printTest() async {
    final printerObj = _buildPrinter();
    if (printerObj == null) return false;

    _status = PrinterStatus.connecting;
    notifyListeners();

    try {
      final connected = await _ftp.connect(printerObj);
      if (!connected) {
        _status = PrinterStatus.error;
        _error = 'Failed to connect';
        notifyListeners();
        return false;
      }

      _status = PrinterStatus.printing;
      notifyListeners();

      final bytes = await ReceiptBuilder.buildTest(_storeConfig);
      await _ftp.printData(printerObj, bytes);

      _status = PrinterStatus.connected;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = PrinterStatus.error;
      _error = 'Test print failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    final printerObj = _buildPrinter();
    if (printerObj != null) {
      await _ftp.disconnect(printerObj);
    }
    _status = PrinterStatus.disconnected;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _status = PrinterStatus.disconnected;
    notifyListeners();
  }
}