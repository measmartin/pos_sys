import 'product_model.dart';

class SalesDetailsDto {
  final int saleId;
  final String saleNumber;
  final DateTime saleDate;
  final int? customerId;
  final String? customerName;
  final String phoneNumber;
  final int currencyId;
  final String? currencyCode;
  final String? currencySymbol;
  final double subtotal;
  final double totalDiscount;
  final double? discountPercentage;
  final double totalAmount;
  final double amountPaid;
  final double changeAmount;
  final String paymentStatus;
  final String saleStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SalesItemDetailsDto> items;

  const SalesDetailsDto({
    required this.saleId,
    required this.saleNumber,
    required this.saleDate,
    this.customerId,
    this.customerName,
    required this.phoneNumber,
    required this.currencyId,
    this.currencyCode,
    this.currencySymbol,
    required this.subtotal,
    required this.totalDiscount,
    this.discountPercentage,
    required this.totalAmount,
    required this.amountPaid,
    required this.changeAmount,
    required this.paymentStatus,
    required this.saleStatus,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory SalesDetailsDto.fromJson(Map<String, dynamic> json) {
    return SalesDetailsDto(
      saleId: json['saleId'] as int,
      saleNumber: json['saleNumber'] as String,
      saleDate: DateTime.parse(json['saleDate'] as String),
      customerId: json['customerId'] as int?,
      customerName: json['customerName'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      currencyId: json['currencyId'] as int,
      currencyCode: json['currencyCode'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      saleStatus: json['saleStatus'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  SalesItemDetailsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SalesItemDetailsDto {
  final int salesItemId;
  final int saleId;
  final int lineNumber;
  final int productId;
  final String? productName;
  final int productUnitId;
  final String? unitName;
  final double quantity;
  final double unitPrice;
  final double lineSubtotal;
  final double discountAmount;
  final double? discountPercentage;
  final double lineTotal;
  final String? notes;
  final DateTime createdAt;

  const SalesItemDetailsDto({
    required this.salesItemId,
    required this.saleId,
    required this.lineNumber,
    required this.productId,
    this.productName,
    required this.productUnitId,
    this.unitName,
    required this.quantity,
    required this.unitPrice,
    required this.lineSubtotal,
    required this.discountAmount,
    this.discountPercentage,
    required this.lineTotal,
    this.notes,
    required this.createdAt,
  });

  factory SalesItemDetailsDto.fromJson(Map<String, dynamic> json) {
    return SalesItemDetailsDto(
      salesItemId: json['salesItemId'] as int,
      saleId: json['saleId'] as int,
      lineNumber: json['lineNumber'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String?,
      productUnitId: json['productUnitId'] as int,
      unitName: json['unitName'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineSubtotal: (json['lineSubtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CreateSalesDto {
  final DateTime? saleDate;
  final int? customerId;
  final String phoneNumber;
  final int currencyId;
  final double amountPaid;
  final String paymentStatus;
  final String saleStatus;
  final String? notes;
  final double? discountAmount;
  final double? discountPercentage;
  final List<CreateSalesItemDto> items;

  const CreateSalesDto({
    this.saleDate,
    this.customerId,
    required this.phoneNumber,
    required this.currencyId,
    required this.amountPaid,
    this.paymentStatus = 'PAID',
    this.saleStatus = 'COMPLETED',
    this.notes,
    this.discountAmount,
    this.discountPercentage,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        if (saleDate != null) 'saleDate': saleDate!.toIso8601String(),
        if (customerId != null) 'customerId': customerId,
        'phoneNumber': phoneNumber,
        'currencyId': currencyId,
        'amountPaid': amountPaid,
        'paymentStatus': paymentStatus,
        'saleStatus': saleStatus,
        if (notes != null) 'notes': notes,
        if (discountAmount != null) 'discountAmount': discountAmount,
        if (discountPercentage != null)
          'discountPercentage': discountPercentage,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class CreateSalesItemDto {
  final int productId;
  final int productUnitId;
  final double quantity;
  final double unitPrice;
  final double? discountPercentage;
  final double? discountAmount;
  final String? notes;

  const CreateSalesItemDto({
    required this.productId,
    required this.productUnitId,
    required this.quantity,
    required this.unitPrice,
    this.discountPercentage,
    this.discountAmount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productUnitId': productUnitId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (discountPercentage != null) 'discountPercentage': discountPercentage,
        if (discountAmount != null) 'discountAmount': discountAmount,
        if (notes != null) 'notes': notes,
      };
}

// Cart item for local POS state
class CartItem {
  final int productId;
  int productUnitId;
  final String productName;
  String? unitName;
  String? unitCode;
  String? imageUrl;
  double unitPrice;
  String? currencySymbol;
  String? currencyCode;
  final List<ProductUnitDetailsDto> availableUnits;
  double quantity;
  double? discountAmount;
  double? discountPercentage;

  CartItem({
    required this.productId,
    required this.productUnitId,
    required this.productName,
    this.unitName,
    this.unitCode,
    this.imageUrl,
    required this.unitPrice,
    this.currencySymbol,
    this.currencyCode,
    this.availableUnits = const [],
    this.quantity = 1,
    this.discountAmount,
    this.discountPercentage,
  });

  double get lineSubtotal => quantity * unitPrice;

  double get effectiveDiscount {
    if (discountAmount != null && discountAmount! > 0) return discountAmount!;
    if (discountPercentage != null && discountPercentage! > 0) {
      return lineSubtotal * discountPercentage! / 100;
    }
    return 0;
  }

  double get lineTotal => lineSubtotal - effectiveDiscount;

  double lineTotalInCurrency(double rate) => lineTotal * rate;
  double unitPriceInCurrency(double rate) => unitPrice * rate;
}
