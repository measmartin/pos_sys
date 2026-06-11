import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/currency_model.dart';
import '../../../providers/currency_provider.dart';

class CurrencyFormSheet extends StatefulWidget {
  final CurrencyDetailsDto? currency;
  const CurrencyFormSheet({this.currency});
  @override
  State<CurrencyFormSheet> createState() => _CurrencyFormSheetState();
}

class _CurrencyFormSheetState extends State<CurrencyFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _symbolCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  bool _isBaseCurrency = false;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.currency != null) {
      _nameCtrl.text = widget.currency!.currencyName;
      _codeCtrl.text = widget.currency!.currencyCode;
      _symbolCtrl.text = widget.currency!.currencySymbol ?? '';
      _rateCtrl.text = widget.currency!.exchangeRate.toString();
      _isBaseCurrency = widget.currency!.isBaseCurrency;
      _isActive = widget.currency!.isActive;
    } else {
      _rateCtrl.text = '1.0';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _symbolCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.currency != null;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? 'Edit Currency' : 'New Currency',
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _field(
                _nameCtrl,
                'Currency Name',
                required: true,
                hint: 'e.g., US Dollar',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _codeCtrl,
                      'Code',
                      required: true,
                      hint: 'USD',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _symbolCtrl,
                      'Symbol',
                      required: false,
                      hint: '\$',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                _rateCtrl,
                'Exchange Rate',
                required: true,
                type: TextInputType.numberWithOptions(decimal: true),
                hint: '1.0',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isBaseCurrency,
                onChanged: isEdit && widget.currency!.isBaseCurrency
                    ? null
                    : (v) => setState(() => _isBaseCurrency = v),
                title: Text(
                  'Base Currency',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Primary currency for the system',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
              ),
              if (isEdit) ...[
                SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: Text(
                    'Active',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Currency' : 'Add Currency',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = true,
    TextInputType? type,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha:0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: required
          ? (v) => v?.isEmpty == true ? 'Required' : null
          : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final isEdit = widget.currency != null;
    bool success;

    if (isEdit) {
      final dto = {
        'currencyName': _nameCtrl.text.trim(),
        'currencyCode': _codeCtrl.text.trim().toUpperCase(),
        if (_symbolCtrl.text.isNotEmpty)
          'currencySymbol': _symbolCtrl.text.trim(),
        'exchangeRate': double.parse(_rateCtrl.text.trim()),
        'isBaseCurrency': _isBaseCurrency,
        'isActive': _isActive,
      };
      success = await context.read<CurrencyProvider>().updateCurrency(
        widget.currency!.currencyId,
        dto,
      );
    } else {
      final dto = {
        'currencyName': _nameCtrl.text.trim(),
        'currencyCode': _codeCtrl.text.trim().toUpperCase(),
        if (_symbolCtrl.text.isNotEmpty)
          'currencySymbol': _symbolCtrl.text.trim(),
        'exchangeRate': double.parse(_rateCtrl.text.trim()),
        'isBaseCurrency': _isBaseCurrency,
      };
      success = await context.read<CurrencyProvider>().createCurrency(dto);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Currency updated successfully'
                  : 'Currency added successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<CurrencyProvider>().error ??
                  'Failed to save currency',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
