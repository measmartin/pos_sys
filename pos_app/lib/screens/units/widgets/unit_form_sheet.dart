import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unit_model.dart';
import '../../../providers/unit_provider.dart';

class UnitFormSheet extends StatefulWidget {
  final UnitDetailsDto? unit;
  const UnitFormSheet({this.unit});
  @override
  State<UnitFormSheet> createState() => _UnitFormSheetState();
}

class _UnitFormSheetState extends State<UnitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.unit != null) {
      _nameCtrl.text = widget.unit!.unitName;
      _codeCtrl.text = widget.unit!.unitCode;
      _descCtrl.text = widget.unit!.description ?? '';
      _isActive = widget.unit!.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.unit != null;
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
                isEdit ? 'Edit Unit' : 'New Unit',
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _field(_nameCtrl, 'Unit Name', required: true),
              const SizedBox(height: 12),
              _field(
                _codeCtrl,
                'Unit Code',
                required: true,
                hint: 'e.g., KG, PCS, L',
              ),
              const SizedBox(height: 12),
              _field(_descCtrl, 'Description', required: false, maxLines: 3),
              if (isEdit) ...[
                const SizedBox(height: 16),
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
                          isEdit ? 'Update Unit' : 'Add Unit',
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
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
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

    final isEdit = widget.unit != null;
    bool success;

    if (isEdit) {
      final dto = {
        'unitName': _nameCtrl.text.trim(),
        'unitCode': _codeCtrl.text.trim().toUpperCase(),
        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
        'isActive': _isActive,
      };
      success = await context.read<UnitProvider>().updateUnit(
        widget.unit!.unitId,
        dto,
      );
    } else {
      final dto = {
        'unitName': _nameCtrl.text.trim(),
        'unitCode': _codeCtrl.text.trim().toUpperCase(),
        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
      };
      success = await context.read<UnitProvider>().createUnit(dto);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'Unit updated successfully' : 'Unit added successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<UnitProvider>().error ?? 'Failed to save unit',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
