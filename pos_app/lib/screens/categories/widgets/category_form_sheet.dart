import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryFormSheet extends StatefulWidget {
  final CategoryDetailsDto? category;
  const CategoryFormSheet({this.category});
  @override
  State<CategoryFormSheet> createState() => CategoryFormSheetState();
}

class CategoryFormSheetState extends State<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameCtrl.text = widget.category!.categoryName;
      _descCtrl.text = widget.category!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.category != null;
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
                isEdit ? 'Edit Category' : 'New Category',
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _field(_nameCtrl, 'Category Name', required: true),
              const SizedBox(height: 12),
              _field(_descCtrl, 'Description', required: false, maxLines: 3),
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
                          isEdit ? 'Update Category' : 'Add Category',
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
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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

    final isEdit = widget.category != null;
    bool success;

    if (isEdit) {
      final dto = {
        'categoryName': _nameCtrl.text.trim(),
        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
      };
      success = await context.read<CategoryProvider>().updateCategory(
        widget.category!.categoryId,
        dto,
      );
    } else {
      final dto = {
        'categoryName': _nameCtrl.text.trim(),
        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
      };
      success = await context.read<CategoryProvider>().createCategory(dto);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Category updated successfully'
                  : 'Category added successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<CategoryProvider>().error ??
                  'Failed to save category',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
