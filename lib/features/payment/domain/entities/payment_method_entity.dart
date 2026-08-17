class PaymentMethodEntity {
  final String id;
  final String name;
  final String iconUrl;
  final String description;
  final bool isDefault;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.description,
    required this.isDefault,
  });

  factory PaymentMethodEntity.fromJson(Map<String, dynamic> json) {
    return PaymentMethodEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
