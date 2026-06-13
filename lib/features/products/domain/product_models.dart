enum ProductStatus { active, inactive, outOfStock, draft }

class Category {
  final int id;
  final String name;
  final int? parentId;
  final String? imageUrl;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        parentId: json['parent_id'] as int?,
        imageUrl: json['image_url'] as String?,
        sortOrder: json['sort_order'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (parentId != null) 'parent_id': parentId,
        if (imageUrl != null) 'image_url': imageUrl,
        'sort_order': sortOrder,
      };
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final int stock;
  final ProductStatus status;
  final List<String> imageUrls;
  final int? categoryId;
  final String? category;
  final String? brand;
  final String? unit;
  final List<String> tags;
  final Map<String, String> specifications;
  final List<String> colorVariations;
  final double? latitude;
  final double? longitude;
  final int viewCount;
  final bool isSponsored;
  final String sponsorStatus;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final String? videoUrl;
  final bool isDraft;
  final DateTime? draftSavedAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.stock,
    required this.status,
    required this.imageUrls,
    this.categoryId,
    this.category,
    this.brand,
    this.unit,
    this.tags = const [],
    this.specifications = const {},
    this.colorVariations = const [],
    this.latitude,
    this.longitude,
    this.viewCount = 0,
    this.isSponsored = false,
    this.sponsorStatus = 'none',
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.videoUrl,
    this.isDraft = false,
    this.draftSavedAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      originalPrice:
          double.tryParse(json['original_price']?.toString() ?? ''),
      discountPercentage: json['discount_percentage'] as int?,
      stock: json['stock'] as int? ?? 0,
      status: json['is_draft'] == true
          ? ProductStatus.draft
          : ProductStatus.values.firstWhere(
              (s) => s.name == (json['status'] as String? ?? 'active'),
              orElse: () => ProductStatus.active,
            ),
      imageUrls: (json['images'] as List?)
              ?.map((e) => e is String ? e : e['url'] as String)
              .toList() ??
          [],
      categoryId: json['category_id'] as int?,
      category: json['category'] as String? ?? json['category_name'] as String?,
      brand: json['brand'] as String?,
      unit: json['unit'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'] as Map)
          : {},
      colorVariations:
          (json['color_variations'] as List?)?.cast<String>() ?? [],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      viewCount: json['view_count'] as int? ?? 0,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      sponsorStatus: json['sponsor_request_status'] as String? ?? 'none',
      isFeatured: json['is_featured'] as bool? ?? false,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      videoUrl: json['video_url'] as String?,
      isDraft: json['is_draft'] as bool? ?? false,
      draftSavedAt: json['draft_saved_at'] != null
          ? DateTime.tryParse(json['draft_saved_at'] as String)
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        if (originalPrice != null) 'original_price': originalPrice,
        if (discountPercentage != null) 'discount_percentage': discountPercentage,
        'stock': stock,
        'status': status.name,
        'images': imageUrls,
        if (categoryId != null) 'category_id': categoryId,
        if (category != null) 'category': category,
        if (brand != null) 'brand': brand,
        if (unit != null) 'unit': unit,
        'tags': tags,
        'specifications': specifications,
        'color_variations': colorVariations,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'view_count': viewCount,
        'is_sponsored': isSponsored,
        'sponsor_request_status': sponsorStatus,
        'is_featured': isFeatured,
        'rating': rating,
        'review_count': reviewCount,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

class ProductForm {
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final int stock;
  final String status;
  final int? categoryId;
  final String? brand;
  final String? unit;
  final List<String> tags;
  final Map<String, String> specifications;
  final List<String> colorVariations;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final bool isDraft;
  final bool removeVideo;

  const ProductForm({
    required this.name,
    this.description = '',
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.stock,
    this.status = 'active',
    this.categoryId,
    this.brand,
    this.unit,
    this.tags = const [],
    this.specifications = const {},
    this.colorVariations = const [],
    this.latitude,
    this.longitude,
    this.images = const [],
    this.isDraft = false,
    this.removeVideo = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'status': status,
        if (originalPrice != null) 'original_price': originalPrice,
        if (discountPercentage != null)
          'discount_percentage': discountPercentage,
        if (categoryId != null) 'category_id': categoryId,
        if (brand != null && brand!.isNotEmpty) 'brand': brand,
        if (unit != null) 'unit': unit,
        if (tags.isNotEmpty) 'tags': tags,
        if (specifications.isNotEmpty) 'specifications': specifications,
        if (colorVariations.isNotEmpty) 'color_variations': colorVariations,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (images.isNotEmpty) 'images': images,
        'is_draft': isDraft,
        if (removeVideo) 'remove_video': true,
      };
}
