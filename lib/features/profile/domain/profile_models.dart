class VendorProfile {
  final int id;
  final String businessName;
  final String email;
  final String phone;
  final String? logoUrl;

  const VendorProfile({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phone,
    this.logoUrl,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}
