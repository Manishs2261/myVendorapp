class VendorProfile {
  final int id;
  final String businessName;
  final String email;
  final String phone;
  final String? logoUrl;
  final String? gstNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const VendorProfile({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phone,
    this.logoUrl,
    this.gstNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      email: json['business_email'] as String? ?? json['email'] as String? ?? '',
      phone: json['business_phone'] as String? ?? json['phone'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      gstNumber: json['gst_number'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_name': businessName,
        'business_email': email,
        'business_phone': phone,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (gstNumber != null) 'gst_number': gstNumber,
        'is_email_verified': isEmailVerified,
        'is_phone_verified': isPhoneVerified,
      };
}
