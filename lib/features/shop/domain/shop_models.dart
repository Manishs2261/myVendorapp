class Shop {
  final int id;
  final String businessName;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String status;
  final bool verified;

  const Shop({
    required this.id,
    required this.businessName,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.status,
    required this.verified,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      verified: json['verified'] as bool? ?? false,
    );
  }
}
