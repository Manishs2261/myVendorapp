enum ProductStatus { active, inactive, outOfStock }

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
      status: ProductStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'active'),
        orElse: () => ProductStatus.active,
      ),
      imageUrls: (json['images'] as List?)
              ?.map((e) => e is String ? e : e['url'] as String)
              .toList() ??
          [],
      categoryId: json['category_id'] as int?,
      category: json['category'] as String?,
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
    );
  }
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
      };
}
