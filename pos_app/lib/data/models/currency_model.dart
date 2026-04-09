class CurrencyDetailsDto {
  final int currencyId;
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final double exchangeRate;
  final bool isBaseCurrency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CurrencyDetailsDto({
    required this.currencyId,
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    required this.exchangeRate,
    required this.isBaseCurrency,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory CurrencyDetailsDto.fromJson(Map<String, dynamic> json) {
    return CurrencyDetailsDto(
      currencyId: json['currencyId'] as int,
      currencyCode: json['currencyCode'] as String,
      currencyName: json['currencyName'] as String,
      currencySymbol: json['currencySymbol'] as String?,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      isBaseCurrency: json['isBaseCurrency'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'currencyId': currencyId,
        'currencyCode': currencyCode,
        'currencyName': currencyName,
        'currencySymbol': currencySymbol,
        'exchangeRate': exchangeRate,
        'isBaseCurrency': isBaseCurrency,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class CreateCurrencyDto {
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final double exchangeRate;
  final bool isBaseCurrency;

  const CreateCurrencyDto({
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    this.exchangeRate = 1.0,
    this.isBaseCurrency = false,
  });

  Map<String, dynamic> toJson() => {
        'currencyCode': currencyCode,
        'currencyName': currencyName,
        if (currencySymbol != null) 'currencySymbol': currencySymbol,
        'exchangeRate': exchangeRate,
        'isBaseCurrency': isBaseCurrency,
      };
}

class UpdateCurrencyDto {
  final String? currencyCode;
  final String? currencyName;
  final String? currencySymbol;
  final double? exchangeRate;
  final bool? isBaseCurrency;
  final bool? isActive;

  const UpdateCurrencyDto({
    this.currencyCode,
    this.currencyName,
    this.currencySymbol,
    this.exchangeRate,
    this.isBaseCurrency,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (currencyCode != null) 'currencyCode': currencyCode,
        if (currencyName != null) 'currencyName': currencyName,
        if (currencySymbol != null) 'currencySymbol': currencySymbol,
        if (exchangeRate != null) 'exchangeRate': exchangeRate,
        if (isBaseCurrency != null) 'isBaseCurrency': isBaseCurrency,
        if (isActive != null) 'isActive': isActive,
      };
}
