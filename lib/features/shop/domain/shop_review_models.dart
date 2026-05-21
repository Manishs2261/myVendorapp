class ShopReview {
  final int id;
  final String reviewerName;
  final String? reviewerAvatar;
  final int rating;
  final String? comment;
  final List<String> images;
  final int helpfulCount;
  final int reportCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ShopReview({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    this.comment,
    required this.images,
    required this.helpfulCount,
    required this.reportCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory ShopReview.fromJson(Map<String, dynamic> json) {
    return ShopReview(
      id: json['id'] as int,
      reviewerName: json['reviewer_name'] as String? ?? 'Anonymous',
      reviewerAvatar: json['reviewer_avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      helpfulCount: json['helpful_count'] as int? ?? 0,
      reportCount: json['report_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

class ShopReviewStats {
  final double averageRating;
  final int totalReviews;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  const ShopReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory ShopReviewStats.fromJson(Map<String, dynamic> json) {
    return ShopReviewStats(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      fiveStar: json['five_star'] as int? ?? 0,
      fourStar: json['four_star'] as int? ?? 0,
      threeStar: json['three_star'] as int? ?? 0,
      twoStar: json['two_star'] as int? ?? 0,
      oneStar: json['one_star'] as int? ?? 0,
    );
  }
}

class ShopReviewsPage {
  final List<ShopReview> items;
  final int total;
  final int page;
  final int pages;

  const ShopReviewsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory ShopReviewsPage.fromJson(Map<String, dynamic> json) {
    return ShopReviewsPage(
      items: (json['items'] as List?)
              ?.map((e) => ShopReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
    );
  }
}
