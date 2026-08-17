class RoleEntity {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final DateTime createdAt;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.createdAt,
  });

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    return RoleEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
