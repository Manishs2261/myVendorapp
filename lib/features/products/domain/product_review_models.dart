class ProductReview {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final String reviewerName;
  final String? reviewerAvatar;
  final int rating;
  final String? comment;
  final bool isVerifiedPurchase;
  final DateTime createdAt;
  final List<String> images;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    this.comment,
    required this.isVerifiedPurchase,
    required this.createdAt,
    this.images = const [],
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      productImage: json['product_image'] as String?,
      reviewerName: json['reviewer_name'] as String? ?? 'Customer',
      reviewerAvatar: json['reviewer_avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      images: (json['images'] as List?)?.cast<String>() ?? [],
    );
  }
}

class ProductReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> breakdown;

  const ProductReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
  });

  int get fiveStar => breakdown['5'] ?? 0;
  int get fourStar => breakdown['4'] ?? 0;
  int get threeStar => breakdown['3'] ?? 0;
  int get twoStar => breakdown['2'] ?? 0;
  int get oneStar => breakdown['1'] ?? 0;

  factory ProductReviewStats.fromJson(Map<String, dynamic> json) {
    final raw = json['breakdown'] as Map<String, dynamic>? ?? {};
    return ProductReviewStats(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      breakdown: raw.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}

class ProductReviewsPage {
  final List<ProductReview> items;
  final int total;
  final int page;
  final int pages;

  const ProductReviewsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory ProductReviewsPage.fromJson(Map<String, dynamic> json) {
    return ProductReviewsPage(
      items: (json['items'] as List?)
              ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
    );
  }
}
