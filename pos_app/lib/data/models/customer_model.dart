class CustomerDetailsDto {
  final int customerId;
  final String? customerName;
  final String? phoneNumber;
  final String? email;
  final String? location;
  final String? city;
  final String? country;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerDetailsDto({
    required this.customerId,
    this.customerName,
    this.phoneNumber,
    this.email,
    this.location,
    this.city,
    this.country,
    this.notes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory CustomerDetailsDto.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsDto(
      customerId: json['customerId'] as int,
      customerName: json['customerName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      location: json['location'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'email': email,
        'location': location,
        'city': city,
        'country': country,
        'notes': notes,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  String get displayName => customerName ?? 'Walk-in Customer';
  String get initials {
    if (customerName == null || customerName!.isEmpty) return 'W';
    final parts = customerName!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}

class CreateCustomerDto {
  final String? customerName;
  final String? phoneNumber;
  final String? email;
  final String? location;
  final String? city;
  final String? country;
  final String? notes;

  const CreateCustomerDto({
    this.customerName,
    this.phoneNumber,
    this.email,
    this.location,
    this.city,
    this.country,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        if (customerName != null) 'customerName': customerName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
        if (location != null) 'location': location,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (notes != null) 'notes': notes,
      };
}




