class ProductDetailsDto {
  final int productId;
  final String productCode;
  final String productName;
  final int categoryId;
  final String? categoryName;
  final int baseUnitId;
  final String? baseUnitName;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ProductUnitDetailsDto> units;

  const ProductDetailsDto({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.categoryId,
    this.categoryName,
    required this.baseUnitId,
    this.baseUnitName,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.units = const [],
  });

  factory ProductDetailsDto.fromJson(Map<String, dynamic> json) {
    return ProductDetailsDto(
      productId: json['productId'] as int,
      productCode: json['productCode'] as String,
      productName: json['productName'] as String,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String?,
      baseUnitId: json['baseUnitId'] as int,
      baseUnitName: json['baseUnitName'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      units: (json['units'] as List<dynamic>?)
              ?.map((e) =>
                  ProductUnitDetailsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productCode': productCode,
        'productName': productName,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'baseUnitId': baseUnitId,
        'baseUnitName': baseUnitName,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class ProductUnitDetailsDto {
  final int productUnitId;
  final int productId;
  final String? productName;
  final int unitId;
  final String? unitName;
  final String? unitCode;
  final int? currencyId;
  final String? currencyCode;
  final String? currencySymbol;
  final bool isBaseCurrency;
  final double conversionRate;
  final double price;
  final bool isDefault;
  final bool isActive;
  final String? imagePath;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductUnitDetailsDto({
    required this.productUnitId,
    required this.productId,
    this.productName,
    required this.unitId,
    this.unitName,
    this.unitCode,
    this.currencyId,
    this.currencyCode,
    this.currencySymbol,
    this.isBaseCurrency = false,
    required this.conversionRate,
    required this.price,
    required this.isDefault,
    required this.isActive,
    this.imagePath,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductUnitDetailsDto.fromJson(Map<String, dynamic> json) {
    return ProductUnitDetailsDto(
      productUnitId: json['productUnitId'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String?,
      unitId: json['unitId'] as int,
      unitName: json['unitName'] as String?,
      unitCode: json['unitCode'] as String?,
      currencyId: json['currencyId'] as int?,
      currencyCode: json['currencyCode'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
      isBaseCurrency: json['isBaseCurrency'] as bool? ?? false,
      conversionRate: (json['conversionRate'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      isDefault: json['isDefault'] as bool,
      isActive: json['isActive'] as bool,
      imagePath: json['imagePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

class CreateProductDto {
  final String productCode;
  final String productName;
  final int categoryId;
  final int baseUnitId;
  final String? description;

  const CreateProductDto({
    required this.productCode,
    required this.productName,
    required this.categoryId,
    required this.baseUnitId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'productCode': productCode,
        'productName': productName,
        'categoryId': categoryId,
        'baseUnitId': baseUnitId,
        if (description != null) 'description': description,
      };
}
