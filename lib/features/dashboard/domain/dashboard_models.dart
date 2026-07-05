class RecentProduct {
  final int id;
  final String name;
  final String? categoryName;
  final double price;
  final String status;
  final int clickCount;
  final List<String> imageUrls;

  const RecentProduct({
    required this.id,
    required this.name,
    this.categoryName,
    required this.price,
    required this.status,
    required this.clickCount,
    required this.imageUrls,
  });

  factory RecentProduct.fromJson(Map<String, dynamic> json) {
    return RecentProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryName: json['category_name'] as String?,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      status: json['status'] as String? ?? 'active',
      clickCount: json['click_count'] as int? ?? 0,
      imageUrls:
          (json['images'] as List?)
              ?.map((e) => e is Map ? e['url'] as String? ?? '' : e as String)
              .where((u) => u.isNotEmpty)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (categoryName != null) 'category_name': categoryName,
    'price': price,
    'status': status,
    'click_count': clickCount,
    'images': imageUrls.map((u) => {'url': u}).toList(),
  };
}

class DashboardOverview {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int pendingOrders;
  final int activeProducts;
  final int inactiveProducts;
  final int totalViews;
  final int completionScore;
  final bool? isVerified;
  final bool? verificationRequested;
  final List<RecentProduct> recentProducts;

  const DashboardOverview({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.pendingOrders,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.totalViews,
    this.completionScore = 0,
    this.isVerified,
    this.verificationRequested,
    required this.recentProducts,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      activeProducts: json['active_products'] as int? ?? 0,
      inactiveProducts: json['inactive_products'] as int? ?? 0,
      totalViews: json['total_views'] as int? ?? 0,
      isVerified: json["is_verified"],
      verificationRequested: json["verification_requested"],
      completionScore: json['completion_score'] as int? ?? 0,
      recentProducts:
          (json['recent_products'] as List?)
              ?.map((e) => RecentProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'total_revenue': totalRevenue,
    'total_orders': totalOrders,
    'total_products': totalProducts,
    'pending_orders': pendingOrders,
    'active_products': activeProducts,
    'inactive_products': inactiveProducts,
    'total_views': totalViews,
    "is_verified": isVerified,
    "verification_requested": verificationRequested,
    'completion_score': completionScore,
    'recent_products': recentProducts.map((p) => p.toJson()).toList(),
  };
}
