enum ProductStatus { active, inactive, outOfStock }

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final ProductStatus status;
  final List<String> imageUrls;
  final String? category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.status,
    required this.imageUrls,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      status: ProductStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'active'),
        orElse: () => ProductStatus.active,
      ),
      imageUrls: (json['images'] as List?)
              ?.map((e) => e['url'] as String)
              .toList() ??
          [],
      category: json['category'] as String?,
    );
  }
}

class ProductForm {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String status;
  final String? category;

  const ProductForm({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.status = 'active',
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'status': status,
        if (category != null) 'category': category,
      };
}
