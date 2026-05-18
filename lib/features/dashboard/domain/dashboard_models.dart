class DashboardOverview {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int pendingOrders;

  const DashboardOverview({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.pendingOrders,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
    );
  }
}
