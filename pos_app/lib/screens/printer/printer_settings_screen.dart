import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/printing/printer_provider.dart';
import '../../core/printing/printer_settings.dart';
import '../../core/theme/app_theme.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _storeNameCtrl = TextEditingController();
  final _storeAddrCtrl = TextEditingController();
  final _storePhoneCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<PrinterProvider>();
    _storeNameCtrl.text = p.storeConfig.name;
    _storeAddrCtrl.text = p.storeConfig.address;
    _storePhoneCtrl.text = p.storeConfig.phone;
    if (p.printerConfig != null) {
      _ipCtrl.text = p.printerConfig!.address;
    }
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeAddrCtrl.dispose();
    _storePhoneCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  void _selectDiscovered(Printer printer) {
    final type = printer.connectionType == ConnectionType.USB
        ? PrinterType.usb
        : PrinterType.network;
    final config = PrinterConfig(
      type: type,
      address: printer.address ?? printer.name ?? '',
      displayName: printer.name ?? 'Printer',
    );
    _ipCtrl.text = config.address;
    context.read<PrinterProvider>().selectPrinter(config);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${config.displayName}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _saveManual() {
    if (_ipCtrl.text.trim().isEmpty) return;
    final config = PrinterConfig(
      type: PrinterType.network,
      address: _ipCtrl.text.trim(),
      displayName: _ipCtrl.text.trim(),
    );
    context.read<PrinterProvider>().selectPrinter(config);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printer saved'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _saveStore() {
    final p = context.read<PrinterProvider>();
    p.updateStoreConfig(StoreConfig(
      name: _storeNameCtrl.text.trim().isEmpty
          ? 'Amrit POS'
          : _storeNameCtrl.text.trim(),
      address: _storeAddrCtrl.text.trim(),
      phone: _storePhoneCtrl.text.trim(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store details saved'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PrinterProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Printer Settings',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Details',
              style: GoogleFonts.notoSerif(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _storeNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                hintText: 'Amrit POS',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storeAddrCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: '123 Street, City',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storePhoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '012 345 678',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _saveStore,
                child: const Text('Save Store Details'),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Printer Connection',
              style: GoogleFonts.notoSerif(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (p.printerConfig != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.print, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.printerConfig!.displayName,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            p.printerConfig!.address,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusIcon(p.status),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.print_disabled, color: AppColors.outline),
                    const SizedBox(width: 12),
                    Text(
                      'No printer configured',
                      style: GoogleFonts.inter(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Printer Name / Address',
                      hintText: 'USB printer name or IP',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _saveManual,
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            FilledButton.tonal(
              onPressed: p.scanning ? null : () => p.scanPrinters(),
              child: p.scanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Scan for Printers'),
            ),
            if (p.discoveredPrinters.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...p.discoveredPrinters.map((d) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.print_outlined),
                    title: Text(d.name ?? 'Unknown'),
                    subtitle: Text(d.address ?? d.vendorId ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _selectDiscovered(d),
                  )),
            ],
            const SizedBox(height: 28),

            Text(
              'Auto-Print',
              style: GoogleFonts.notoSerif(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Print receipt automatically on sale',
                style: GoogleFonts.inter(),
              ),
              value: p.autoPrint,
              activeColor: AppColors.primary,
              onChanged: (v) => p.setAutoPrint(v),
            ),
            const SizedBox(height: 28),

            Text(
              'Test Print',
              style: GoogleFonts.notoSerif(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: p.isConfigured ? () => p.printTest() : null,
              child: const Text('Print Test Receipt'),
            ),
            if (p.error != null) ...[
              const SizedBox(height: 8),
              Text(
                p.error!,
                style: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(PrinterStatus status) {
    switch (status) {
      case PrinterStatus.connected:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case PrinterStatus.printing:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PrinterStatus.connecting:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PrinterStatus.error:
        return const Icon(Icons.error, color: AppColors.error, size: 20);
      case PrinterStatus.disconnected:
        return const Icon(Icons.cloud_off,
            color: AppColors.outline, size: 20);
    }
  }
}