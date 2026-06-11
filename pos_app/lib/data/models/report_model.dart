class SalesSummaryDto {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalRevenue;
  final double totalDiscount;
  final double totalAmountPaid;
  final double totalChange;
  final int transactionCount;
  final double avgOrderValue;
  final String? currencyCode;
  final String? currencySymbol;

  const SalesSummaryDto({
    required this.periodStart,
    required this.periodEnd,
    required this.totalRevenue,
    required this.totalDiscount,
    required this.totalAmountPaid,
    required this.totalChange,
    required this.transactionCount,
    required this.avgOrderValue,
    this.currencyCode,
    this.currencySymbol,
  });

  factory SalesSummaryDto.fromJson(Map<String, dynamic> json) {
    return SalesSummaryDto(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      totalAmountPaid: (json['totalAmountPaid'] as num).toDouble(),
      totalChange: (json['totalChange'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      avgOrderValue: (json['avgOrderValue'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
    );
  }
}

class DailySalesDto {
  final DateTime date;
  final double revenue;
  final double discount;
  final int transactionCount;
  final double avgOrderValue;

  const DailySalesDto({
    required this.date,
    required this.revenue,
    required this.discount,
    required this.transactionCount,
    required this.avgOrderValue,
  });

  factory DailySalesDto.fromJson(Map<String, dynamic> json) {
    return DailySalesDto(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      avgOrderValue: (json['avgOrderValue'] as num).toDouble(),
    );
  }
}

class TopProductDto {
  final int productId;
  final String productName;
  final String? categoryName;
  final double totalQuantity;
  final double totalRevenue;
  final int saleCount;

  const TopProductDto({
    required this.productId,
    required this.productName,
    this.categoryName,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.saleCount,
  });

  factory TopProductDto.fromJson(Map<String, dynamic> json) {
    return TopProductDto(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      categoryName: json['categoryName'] as String?,
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      saleCount: json['saleCount'] as int,
    );
  }
}

class CategorySalesDto {
  final int? categoryId;
  final String categoryName;
  final double totalRevenue;
  final int transactionCount;
  final double percentage;

  const CategorySalesDto({
    this.categoryId,
    required this.categoryName,
    required this.totalRevenue,
    required this.transactionCount,
    required this.percentage,
  });

  factory CategorySalesDto.fromJson(Map<String, dynamic> json) {
    return CategorySalesDto(
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class TopCustomerDto {
  final int? customerId;
  final String customerName;
  final String? phoneNumber;
  final double totalSpent;
  final int visitCount;
  final double avgOrderValue;

  const TopCustomerDto({
    this.customerId,
    required this.customerName,
    this.phoneNumber,
    required this.totalSpent,
    required this.visitCount,
    required this.avgOrderValue,
  });

  factory TopCustomerDto.fromJson(Map<String, dynamic> json) {
    return TopCustomerDto(
      customerId: json['customerId'] as int?,
      customerName: json['customerName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      visitCount: json['visitCount'] as int,
      avgOrderValue: (json['avgOrderValue'] as num).toDouble(),
    );
  }
}

class PaymentBreakdownDto {
  final String paymentStatus;
  final int count;
  final double totalAmount;
  final double percentage;

  const PaymentBreakdownDto({
    required this.paymentStatus,
    required this.count,
    required this.totalAmount,
    required this.percentage,
  });

  factory PaymentBreakdownDto.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdownDto(
      paymentStatus: json['paymentStatus'] as String,
      count: json['count'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class CurrencyInfoDto {
  final int currencyId;
  final String currencyCode;
  final String currencySymbol;
  final double exchangeRate;
  final bool isBaseCurrency;

  const CurrencyInfoDto({
    required this.currencyId,
    required this.currencyCode,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.isBaseCurrency,
  });

  factory CurrencyInfoDto.fromJson(Map<String, dynamic> json) {
    return CurrencyInfoDto(
      currencyId: json['currencyId'] as int,
      currencyCode: json['currencyCode'] as String,
      currencySymbol: json['currencySymbol'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      isBaseCurrency: json['isBaseCurrency'] as bool,
    );
  }
}

class SalesExportDto {
  final String saleNumber;
  final DateTime saleDate;
  final String? customerName;
  final String phoneNumber;
  final String currencyCode;
  final double subtotal;
  final double totalDiscount;
  final double totalAmount;
  final double amountPaid;
  final double changeAmount;
  final String paymentStatus;
  final String saleStatus;
  final String? notes;

  const SalesExportDto({
    required this.saleNumber,
    required this.saleDate,
    this.customerName,
    required this.phoneNumber,
    required this.currencyCode,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalAmount,
    required this.amountPaid,
    required this.changeAmount,
    required this.paymentStatus,
    required this.saleStatus,
    this.notes,
  });

  factory SalesExportDto.fromJson(Map<String, dynamic> json) {
    return SalesExportDto(
      saleNumber: json['saleNumber'] as String,
      saleDate: DateTime.parse(json['saleDate'] as String),
      customerName: json['customerName'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      currencyCode: json['currencyCode'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      saleStatus: json['saleStatus'] as String,
      notes: json['notes'] as String?,
    );
  }
}
