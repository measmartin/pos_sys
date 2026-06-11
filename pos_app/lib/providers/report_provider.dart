import 'package:flutter/foundation.dart';
import 'package:pos_app/data/models/report_model.dart';
import 'package:pos_app/data/services/api_service.dart';
import 'package:pos_app/utils/export_excel.dart';
import 'package:pos_app/utils/export_pdf.dart';

enum ReportTab { sales, products, customers, payments }

enum DatePreset {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last30Days,
  thisYear,
  custom,
}

class ReportProvider extends ChangeNotifier {
  final ApiService _api;
  ReportProvider(this._api);

  ReportTab _activeTab = ReportTab.sales;
  ReportTab get activeTab => _activeTab;

  DatePreset _datePreset = DatePreset.last30Days;
  DatePreset get datePreset => _datePreset;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now();
  DateTime get endDate => _endDate;

  int? _selectedCurrencyId;
  int? get selectedCurrencyId => _selectedCurrencyId;

  List<CurrencyInfoDto> _currencies = [];
  List<CurrencyInfoDto> get currencies => _currencies;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  SalesSummaryDto? _salesSummary;
  SalesSummaryDto? get salesSummary => _salesSummary;

  List<DailySalesDto> _dailySales = [];
  List<DailySalesDto> get dailySales => _dailySales;

  List<TopProductDto> _topProducts = [];
  List<TopProductDto> get topProducts => _topProducts;

  List<CategorySalesDto> _categorySales = [];
  List<CategorySalesDto> get categorySales => _categorySales;

  List<TopCustomerDto> _topCustomers = [];
  List<TopCustomerDto> get topCustomers => _topCustomers;

  List<PaymentBreakdownDto> _paymentBreakdown = [];
  List<PaymentBreakdownDto> get paymentBreakdown => _paymentBreakdown;

  List<SalesExportDto> _salesExport = [];
  List<SalesExportDto> get salesExport => _salesExport;

  bool _exporting = false;
  bool get exporting => _exporting;

  void setActiveTab(ReportTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end, {DatePreset preset = DatePreset.custom}) {
    _startDate = start;
    _endDate = end;
    _datePreset = preset;
    notifyListeners();
  }

  void setCurrencyId(int? currencyId) {
    _selectedCurrencyId = currencyId;
    notifyListeners();
  }

  static ({DateTime start, DateTime end}) getDateRangeFromPreset(DatePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime start;
    DateTime end = today;

    switch (preset) {
      case DatePreset.today:
        start = today;
        break;
      case DatePreset.yesterday:
        start = today.subtract(const Duration(days: 1));
        end = start;
        break;
      case DatePreset.thisWeek:
        final day = today.weekday;
        start = today.subtract(Duration(days: day - 1));
        break;
      case DatePreset.lastWeek:
        final day2 = today.weekday;
        start = today.subtract(Duration(days: day2 + 6));
        end = today.subtract(Duration(days: day2));
        break;
      case DatePreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case DatePreset.lastMonth:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case DatePreset.last30Days:
        start = today.subtract(const Duration(days: 30));
        break;
      case DatePreset.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case DatePreset.custom:
      default:
        start = today.subtract(const Duration(days: 30));
    }

    return (start: start, end: end);
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCurrencies(),
        _loadActiveReport(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrencies() async {
    try {
      final data = await _api.getReportCurrencies();
      _currencies = data
          .map((e) => CurrencyInfoDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _currencies = [];
    }
  }

  Future<void> _loadActiveReport() async {
    final endDateAdjusted = _endDate.copyWith(hour: 23, minute: 59, second: 59);

    try {
      switch (_activeTab) {
        case ReportTab.sales:
          await _loadSalesReport(endDateAdjusted);
          break;
        case ReportTab.products:
          await _loadProductReport(endDateAdjusted);
          break;
        case ReportTab.customers:
          await _loadCustomerReport(endDateAdjusted);
          break;
        case ReportTab.payments:
          await _loadPaymentReport(endDateAdjusted);
          break;
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> _loadSalesReport(DateTime endDateAdjusted) async {
    final results = await Future.wait([
      _api.getSalesSummary(
        startDate: _startDate,
        endDate: endDateAdjusted,
        currencyId: _selectedCurrencyId,
      ),
      _api.getDailySales(
        startDate: _startDate,
        endDate: endDateAdjusted,
        currencyId: _selectedCurrencyId,
      ),
      _api.getSalesForExport(
        startDate: _startDate,
        endDate: endDateAdjusted,
        currencyId: _selectedCurrencyId,
      ),
    ]);

    _salesSummary = SalesSummaryDto.fromJson(results[0] as Map<String, dynamic>);
    _dailySales = (results[1] as List<dynamic>)
        .map((e) => DailySalesDto.fromJson(e as Map<String, dynamic>))
        .toList();
    _salesExport = (results[2] as List<dynamic>)
        .map((e) => SalesExportDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _loadProductReport(DateTime endDateAdjusted) async {
    final results = await Future.wait([
      _api.getTopProducts(
        startDate: _startDate,
        endDate: endDateAdjusted,
        currencyId: _selectedCurrencyId,
        topN: 20,
      ),
      _api.getCategorySales(
        startDate: _startDate,
        endDate: endDateAdjusted,
        currencyId: _selectedCurrencyId,
      ),
    ]);

    _topProducts = (results[0] as List<dynamic>)
        .map((e) => TopProductDto.fromJson(e as Map<String, dynamic>))
        .toList();
    _categorySales = (results[1] as List<dynamic>)
        .map((e) => CategorySalesDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _loadCustomerReport(DateTime endDateAdjusted) async {
    final data = await _api.getTopCustomers(
      startDate: _startDate,
      endDate: endDateAdjusted,
      currencyId: _selectedCurrencyId,
      topN: 20,
    );
    _topCustomers = data
        .map((e) => TopCustomerDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _loadPaymentReport(DateTime endDateAdjusted) async {
    final data = await _api.getPaymentBreakdown(
      startDate: _startDate,
      endDate: endDateAdjusted,
      currencyId: _selectedCurrencyId,
    );
    _paymentBreakdown = data
        .map((e) => PaymentBreakdownDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> exportToExcel() async {
    _exporting = true;
    notifyListeners();
    try {
      switch (_activeTab) {
        case ReportTab.sales:
          await ExportExcel.exportSales(_salesExport);
          break;
        case ReportTab.products:
          await ExportExcel.exportProducts(_topProducts);
          break;
        case ReportTab.customers:
          await ExportExcel.exportCustomers(_topCustomers);
          break;
        case ReportTab.payments:
          await ExportExcel.exportPayments(_paymentBreakdown);
          break;
      }
    } catch (e) {
      _error = 'Export failed: $e';
      notifyListeners();
    } finally {
      _exporting = false;
      notifyListeners();
    }
  }

  Future<void> exportToPdf() async {
    _exporting = true;
    notifyListeners();
    try {
      switch (_activeTab) {
        case ReportTab.sales:
          await ExportPdf.exportSales(_salesExport, _salesSummary);
          break;
        case ReportTab.products:
          await ExportPdf.exportProducts(_topProducts);
          break;
        case ReportTab.customers:
          await ExportPdf.exportCustomers(_topCustomers);
          break;
        case ReportTab.payments:
          await ExportPdf.exportPayments(_paymentBreakdown);
          break;
      }
    } catch (e) {
      _error = 'Export failed: $e';
      notifyListeners();
    } finally {
      _exporting = false;
      notifyListeners();
    }
  }
}
