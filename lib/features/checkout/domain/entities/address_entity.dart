class AddressEntity {
  final String id;
  final String label;
  final String region;
  final String district;
  final String street;
  final String building;
  final String apartment;
  final String zipCode;
  final String phone;
  final String notes;
  final bool isDefault;
  final bool isCurrentLocation;
  final String addressType;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.region,
    required this.district,
    required this.street,
    required this.building,
    required this.apartment,
    required this.zipCode,
    required this.phone,
    required this.notes,
    required this.isDefault,
    required this.isCurrentLocation,
    required this.addressType,
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      region: json['region'] as String? ?? '',
      district: json['district'] as String? ?? '',
      street: json['street'] as String? ?? '',
      building: json['building'] as String? ?? '',
      apartment: json['apartment'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      isCurrentLocation: json['is_current_location'] as bool? ?? false,
      addressType: json['address_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'region': region,
      'district': district,
      'street': street,
      'building': building,
      'apartment': apartment,
      'zip_code': zipCode,
      'phone': phone,
      'notes': notes,
      'is_default': isDefault,
      'is_current_location': isCurrentLocation,
      'address_type': addressType,
    };
  }
}
