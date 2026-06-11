import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/currency_model.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';

class ProductUnitEntry {
  int? productUnitId;
  int? unitId;
  String? unitName;
  int? currencyId;
  String? currencyCode;
  String? currencySymbol;
  bool isBaseCurrency;
  double price;
  double conversionRate;
  bool isDefault;
  bool isNew;
  Uint8List? imageBytes;
  String? imageName;

  ProductUnitEntry({
    this.productUnitId,
    this.unitId,
    this.unitName,
    this.currencyId,
    this.currencyCode,
    this.currencySymbol,
    this.isBaseCurrency = false,
    this.price = 0,
    this.conversionRate = 1,
    this.isDefault = false,
    this.isNew = true,
  });

  factory ProductUnitEntry.fromDto(ProductUnitDetailsDto dto) {
    return ProductUnitEntry(
      productUnitId: dto.productUnitId,
      unitId: dto.unitId,
      unitName: dto.unitName,
      currencyId: dto.currencyId,
      currencyCode: dto.currencyCode,
      currencySymbol: dto.currencySymbol,
      isBaseCurrency: dto.isBaseCurrency,
      price: dto.price,
      conversionRate: dto.conversionRate,
      isDefault: dto.isDefault,
      isNew: false,
    );
  }
}

class ProductEditScreen extends StatefulWidget {
  final ProductDetailsDto? product;

  const ProductEditScreen.create({super.key}) : product = null;
  const ProductEditScreen.edit({super.key, required ProductDetailsDto product})
    : product = product;

  bool get isCreate => product == null;

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  int? _categoryId;
  int? _baseUnitId;
  Uint8List? _coverImageBytes;
  String? _coverImageName;
  bool _saving = false;
  final List<ProductUnitEntry> _unitEntries = [];
  final List<int> _deletedProductUnitIds = [];

  ProductDetailsDto? get _product => widget.product;
  bool get _isCreate => widget.isCreate;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: _product?.productCode ?? '');
    _nameCtrl = TextEditingController(text: _product?.productName ?? '');
    _descCtrl = TextEditingController(text: _product?.description ?? '');
    _categoryId = _product?.categoryId;
    _baseUnitId = _product?.baseUnitId;

    if (_product != null) {
      _unitEntries.addAll(_product!.units.map(ProductUnitEntry.fromDto));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.categories.isEmpty) {
        provider.loadCategories();
      }
      if (provider.units.isEmpty) {
        provider.loadUnits();
      }
      if (provider.currencies.isEmpty) {
        provider.loadCurrencies();
      }
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  ProductUnitEntry _blankEntry() {
    return ProductUnitEntry(isDefault: _unitEntries.isEmpty);
  }

  void _addVariant() {
    setState(() {
      for (final entry in _unitEntries) {
        entry.isDefault = false;
      }
      final entry = _blankEntry();
      if (_unitEntries.isEmpty) {
        entry.isDefault = true;
      }
      _unitEntries.add(entry);
    });
  }

  void _confirmRemoveVariant(int index) {
    final entry = _unitEntries[index];
    if (entry.productUnitId == null) {
      _removeVariant(index);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Variant'),
        content: Text('Remove "${entry.unitName ?? 'this variant'}" from the product?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _removeVariant(index);
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _removeVariant(int index) {
    final entry = _unitEntries[index];
    setState(() {
      if (entry.productUnitId != null) {
        _deletedProductUnitIds.add(entry.productUnitId!);
      }
      _unitEntries.removeAt(index);
      if (_unitEntries.isNotEmpty && !_unitEntries.any((e) => e.isDefault)) {
        _unitEntries.first.isDefault = true;
      }
      if (_unitEntries.isEmpty) {
        _coverImageBytes = null;
        _coverImageName = null;
      }
    });
  }

  void _setDefaultVariant(int index) {
    setState(() {
      for (final entry in _unitEntries) {
        entry.isDefault = false;
      }
      _unitEntries[index].isDefault = true;
    });
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.bytes == null || picked.bytes!.isEmpty) return;

    setState(() {
      _coverImageBytes = picked.bytes;
      _coverImageName = picked.name;
    });
  }

  Future<void> _pickVariantImage(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.bytes == null || picked.bytes!.isEmpty) return;

    setState(() {
      _unitEntries[index].imageBytes = picked.bytes;
      _unitEntries[index].imageName = picked.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_unitEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one unit variant')),
      );
      return;
    }
    if (_unitEntries.any((e) => e.unitId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a unit for every variant')),
      );
      return;
    }
    if (_baseUnitId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a base unit')));
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<ProductProvider>();

    try {
      ProductDetailsDto? savedProduct;
      if (_isCreate) {
        savedProduct = await provider.createProduct({
          'productCode': _codeCtrl.text.trim(),
          'productName': _nameCtrl.text.trim(),
          'categoryId': _categoryId,
          'baseUnitId': _baseUnitId,
          if (_descCtrl.text.trim().isNotEmpty)
            'description': _descCtrl.text.trim(),
        });
      } else {
        savedProduct = await provider.updateProduct(_product!.productId, {
          'productName': _nameCtrl.text.trim(),
          'categoryId': _categoryId,
          'description': _descCtrl.text.trim(),
        });
      }

      if (savedProduct == null) {
        throw Exception(provider.error ?? 'Unable to save product');
      }

      final productId = savedProduct.productId;
      for (final deletedId in _deletedProductUnitIds) {
        await provider.deleteProductUnit(deletedId);
      }

      int? coverTargetUnitId;
      for (final entry in _unitEntries) {
        final payload = {
          'productId': productId,
          'unitId': entry.unitId,
          'conversionRate': entry.conversionRate,
          'price': entry.price,
          'isDefault': entry.isDefault,
        };

        if (entry.productUnitId == null) {
          final createdUnitId = await provider.createProductUnit(payload);
          if (createdUnitId != null) {
            entry.productUnitId = createdUnitId;
            if (entry.isDefault) {
              coverTargetUnitId = createdUnitId;
            }
            if (entry.imageBytes != null && entry.imageName != null) {
              await provider.uploadProductUnitImage(
                createdUnitId,
                entry.imageBytes!,
                entry.imageName!,
              );
            }
          }
        } else {
          await provider.updateProductUnit(entry.productUnitId!, payload);
          if (entry.isDefault) {
            coverTargetUnitId = entry.productUnitId;
          }
          if (entry.imageBytes != null && entry.imageName != null) {
            await provider.uploadProductUnitImage(
              entry.productUnitId!,
              entry.imageBytes!,
              entry.imageName!,
            );
          }
        }
      }

      if (_coverImageBytes != null) {
        final targetId =
            coverTargetUnitId ??
            _unitEntries
                .firstWhere(
                  (e) => e.productUnitId != null,
                  orElse: () => _unitEntries.first,
                )
                .productUnitId;
        if (targetId != null) {
          await provider.uploadProductUnitImage(
            targetId,
            _coverImageBytes!,
            _coverImageName ?? 'product_image.jpg',
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCreate
                ? 'Product created successfully'
                : 'Product updated successfully',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final defaultUnit = _unitEntries.isNotEmpty
        ? _unitEntries.firstWhere(
            (entry) => entry.isDefault,
            orElse: () => _unitEntries.first,
          )
        : null;
    final previewUnit = _product?.units.isNotEmpty == true
        ? _product!.units.firstWhere(
            (u) => u.isDefault,
            orElse: () => _product!.units.first,
          )
        : null;
    final currencySymbol = _currencySymbol(
      provider,
      defaultUnit,
      previewUnit,
    );
    final currency = NumberFormat.currency(symbol: currencySymbol);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isCreate ? 'Add Product' : 'Edit Product',
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Icon(Icons.more_vert, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverSection(previewUnit),
                  const SizedBox(height: 24),
                  _buildMetaRow(defaultUnit, currency),
                  const SizedBox(height: 24),
                  _buildIdentityFields(provider),
                  const SizedBox(height: 24),
                  _buildSalesSection(provider, currency),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCoverSection(ProductUnitDetailsDto? previewUnit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_coverImageBytes != null)
                  Image.memory(_coverImageBytes!, fit: BoxFit.cover)
                else if (previewUnit?.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: previewUnit!.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox.expand(
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox.expand(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppColors.outlineVariant,
                      ),
                    ),
                  )
                else
                  const SizedBox.expand(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                Container(
                  color: Colors.black.withValues(alpha:0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.95),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_camera,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _coverImageBytes == null
                                ? 'Curate Primary'
                                : 'Change Image',
                            style: GoogleFonts.publicSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isCreate
                  ? 'CATALOG ENTRY #DRAFT'
                  : 'CATALOG ENTRY #${_product!.productId}',
              style: GoogleFonts.publicSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.outline,
              ),
            ),
            Text(
              _isCreate ? 'UNSAVED RECORD' : 'ARCHIVED RECORD',
              style: GoogleFonts.publicSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.tertiaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaRow(ProductUnitEntry? defaultUnit, NumberFormat currency) {
    return Row(
      children: [
        Expanded(child: _infoBox('Total Units', '${_unitEntries.length}')),
        const SizedBox(width: 12),
        Expanded(
          child: _infoBox(
            'Default Price',
            defaultUnit == null ? '--' : currency.format(defaultUnit.price),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityFields(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledField(
          controller: _codeCtrl,
          label: 'Product Code (SKU)',
          hint: 'ELEC001',
          readOnly: !_isCreate,
          validator: (value) {
            if (_isCreate && (value == null || value.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _labeledField(
          controller: _nameCtrl,
          label: 'Product Name',
          hint: 'Enter product name',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCategoryDropdown(provider)),
            const SizedBox(width: 12),
            Expanded(child: _buildBaseUnitDropdown(provider)),
          ],
        ),
        const SizedBox(height: 16),
        _labeledField(
          controller: _descCtrl,
          label: 'Description',
          hint: 'Optional notes',
          maxLines: 4,
          validator: null,
        ),
      ],
    );
  }

  Widget _buildSalesSection(ProductProvider provider, NumberFormat currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unit Variants',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _addVariant,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Variant'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_unitEntries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha:0.3),
              ),
            ),
            child: Text(
              'No unit variants yet. Add the first sellable unit below.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _unitEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) =>
                _buildVariantCard(provider, index, currency),
          ),
      ],
    );
  }

  Widget _buildVariantCard(
    ProductProvider provider,
    int index,
    NumberFormat currency,
  ) {
    final entry = _unitEntries[index];
    final usedUnitIds = _unitEntries
        .where((e) => e.unitId != null && e != entry)
        .map((e) => e.unitId!)
        .toSet();

    final availableUnits = provider.units
        .where(
          (unit) =>
              entry.unitId == unit.unitId || !usedUnitIds.contains(unit.unitId),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isDefault
              ? AppColors.primary
              : AppColors.outlineVariant.withValues(alpha:0.3),
          width: entry.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _pickVariantImage(index),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha:0.4),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: entry.imageBytes != null
                      ? Image.memory(entry.imageBytes!, fit: BoxFit.cover)
                      : entry.isNew
                      ? const Icon(Icons.add_a_photo, color: AppColors.outline)
                      : const Icon(
                          Icons.image_outlined,
                          color: AppColors.outline,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.isNew ? 'Select Unit' : (entry.unitName ?? 'Unit'),
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (entry.isNew)
                      DropdownButtonFormField<int>(
                        value: entry.unitId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant.withValues(alpha:0.35),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant.withValues(alpha:0.35),
                            ),
                          ),
                        ),
                        items: availableUnits
                            .map(
                              (unit) => DropdownMenuItem<int>(
                                value: unit.unitId,
                                child: Text(unit.unitName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            entry.unitId = value;
                            entry.unitName = provider.units
                                .where((u) => u.unitId == value)
                                .map((u) => u.unitName)
                                .cast<String?>()
                                .firstOrNull;
                          });
                        },
                      )
                    else
                      Text(
                        entry.unitName ?? '',
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.outline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Default'),
                      const SizedBox(width: 6),
                      Switch(
                        value: entry.isDefault,
                        onChanged: (_) => _setDefaultVariant(index),
                      ),
                    ],
                  ),
                  if (_unitEntries.length > 1)
                    IconButton(
                      onPressed: () => _confirmRemoveVariant(index),
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _labeledNumberField(
                  label: 'Conversion Rate',
                  initialValue: entry.conversionRate.toString(),
                  onChanged: (value) {
                    entry.conversionRate = double.tryParse(value) ?? 1;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledNumberField(
                  label: 'Price',
                  initialValue: entry.price.toString(),
                  onChanged: (value) {
                    entry.price = double.tryParse(value) ?? 0;
                  },
                  prefix: currency.currencySymbol,
                ),
              ),
            ],
          ),
          if (entry.isDefault) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Default for POS',
                style: GoogleFonts.publicSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.publicSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _categoryId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
          ),
          items: provider.categories
              .map(
                (category) => DropdownMenuItem<int>(
                  value: category.categoryId,
                  child: Text(category.categoryName),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _categoryId = value),
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildBaseUnitDropdown(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base Unit',
          style: GoogleFonts.publicSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _baseUnitId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
          ),
          items: provider.units
              .map(
                (unit) => DropdownMenuItem<int>(
                  value: unit.unitId,
                  child: Text(unit.unitName),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _baseUnitId = value),
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.96),
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.12)),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            if (!_isCreate)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (!_isCreate) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _saving
                      ? 'Saving...'
                      : (_isCreate ? 'Create Product' : 'Save Changes'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.publicSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _labeledNumberField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    String? prefix,
    bool allowNegative = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            if (!allowNegative && value.startsWith('-')) return;
            onChanged(value);
          },
          inputFormatters: [
            if (!allowNegative)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final num = double.tryParse(value);
            if (num == null) return 'Invalid number';
            if (!allowNegative && num < 0) return 'Cannot be negative';
            return null;
          },
          decoration: InputDecoration(
            prefixText: prefix,
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha:0.35),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String currencyFormat(double value) {
    return NumberFormat.currency(symbol: r'$').format(value);
  }

  String _currencySymbol(
    ProductProvider provider,
    ProductUnitEntry? entry,
    ProductUnitDetailsDto? previewEntry,
  ) {
    final symbol = entry?.currencySymbol;
    if (symbol != null && symbol.isNotEmpty) {
      return symbol;
    }

    final code = entry?.currencyCode;
    if (code != null && code.isNotEmpty) {
      return code;
    }

    final previewSymbol = previewEntry?.currencySymbol;
    if (previewSymbol != null && previewSymbol.isNotEmpty) {
      return previewSymbol;
    }

    final previewCode = previewEntry?.currencyCode;
    if (previewCode != null && previewCode.isNotEmpty) {
      return previewCode;
    }

    final baseCurrency = provider.currencies
        .where((currency) => currency.isBaseCurrency)
        .cast<CurrencyDetailsDto?>()
        .firstOrNull;
    if (baseCurrency?.currencySymbol != null &&
        baseCurrency!.currencySymbol!.isNotEmpty) {
      return baseCurrency.currencySymbol!;
    }
    if (baseCurrency?.currencyCode != null && baseCurrency!.currencyCode.isNotEmpty) {
      return baseCurrency.currencyCode;
    }

    return r'$';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
