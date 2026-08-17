class AdminDashboardEntity {
  final int totalUsers;
  final int activeUsers;

  final int totalProducts;
  final int pendingProducts;
  final int rejectedProducts;
  final int totalOrders;
  final int pendingOrders;
  final double revenue;
  final int complaints;

  const AdminDashboardEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalProducts,
    required this.pendingProducts,
    required this.rejectedProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.revenue,
    required this.complaints,
  });

  factory AdminDashboardEntity.fromJson(Map<String, dynamic> json) {
    return AdminDashboardEntity(
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      pendingProducts: json['pending_products'] as int? ?? 0,
      rejectedProducts: json['rejected_products'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      complaints: json['complaints'] as int? ?? 0,
    );
  }
}
