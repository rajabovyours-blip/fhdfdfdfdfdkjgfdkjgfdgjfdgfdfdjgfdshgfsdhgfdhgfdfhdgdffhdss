class SellerDashboardEntity {
  final int todaySales;
  final int totalSales;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double storeRating;

  SellerDashboardEntity({
    required this.todaySales,
    required this.totalSales,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.storeRating,
  });

  factory SellerDashboardEntity.empty() {
    return SellerDashboardEntity(
      todaySales: 0,
      totalSales: 0,
      pendingOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      lowStockProducts: 0,
      outOfStockProducts: 0,
      storeRating: 0.0,
    );
  }
}
