class PermissionEntity {
  final String id;
  final String resource; // e.g. 'users', 'products'
  final String action; // e.g. 'view', 'manage'
  final String description;

  const PermissionEntity({
    required this.id,
    required this.resource,
    required this.action,
    required this.description,
  });

  factory PermissionEntity.fromJson(Map<String, dynamic> json) {
    return PermissionEntity(
      id: json['id'] as String? ?? '',
      resource: json['resource'] as String? ?? '',
      action: json['action'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  String get permissionString => '$resource.$action';
}
