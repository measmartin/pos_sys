class UnitDetailsDto {
  final int unitId;
  final String unitName;
  final String unitCode;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UnitDetailsDto({
    required this.unitId,
    required this.unitName,
    required this.unitCode,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory UnitDetailsDto.fromJson(Map<String, dynamic> json) {
    return UnitDetailsDto(
      unitId: json['unitId'] as int,
      unitName: json['unitName'] as String,
      unitCode: json['unitCode'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'unitId': unitId,
        'unitName': unitName,
        'unitCode': unitCode,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class CreateUnitDto {
  final String unitName;
  final String unitCode;
  final String? description;

  const CreateUnitDto({
    required this.unitName,
    required this.unitCode,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'unitName': unitName,
        'unitCode': unitCode,
        if (description != null) 'description': description,
      };
}

class UpdateUnitDto {
  final String? unitName;
  final String? unitCode;
  final String? description;
  final bool? isActive;

  const UpdateUnitDto({
    this.unitName,
    this.unitCode,
    this.description,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (unitName != null) 'unitName': unitName,
        if (unitCode != null) 'unitCode': unitCode,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive,
      };
}
