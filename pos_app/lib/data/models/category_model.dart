class CategoryDetailsDto {
  final int categoryId;
  final String categoryName;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryDetailsDto({
    required this.categoryId,
    required this.categoryName,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory CategoryDetailsDto.fromJson(Map<String, dynamic> json) {
    return CategoryDetailsDto(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class CreateCategoryDto {
  final String categoryName;
  final String? description;

  const CreateCategoryDto({
    required this.categoryName,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'categoryName': categoryName,
        if (description != null) 'description': description,
      };
}

class UpdateCategoryDto {
  final String? categoryName;
  final String? description;
  final bool? isActive;

  const UpdateCategoryDto({
    this.categoryName,
    this.description,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (categoryName != null) 'categoryName': categoryName,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive,
      };
}
