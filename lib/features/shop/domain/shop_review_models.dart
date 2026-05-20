class ReviewItem {
  final int id;
  final int rating;
  final String? comment;
  final String reviewerName;

  const ReviewItem({
    required this.id,
    required this.rating,
    this.comment,
    required this.reviewerName,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] as int,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      reviewerName: json['reviewer_name'] as String? ?? 'Anonymous',
    );
  }
}

class ShopReviewStats {
  final double averageRating;
  final int totalReviews;
  final List<ReviewItem> recentReviews;

  const ShopReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.recentReviews,
  });

  factory ShopReviewStats.fromJson(Map<String, dynamic> json) {
    return ShopReviewStats(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      recentReviews: (json['recent_reviews'] as List?)
              ?.map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
