class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String businessName;
  final String email;
  final String password;
  final String phone;

  const RegisterRequest({
    required this.businessName,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'business_name': businessName,
        'email': email,
        'password': password,
        'phone': phone,
      };
}

class VendorUser {
  final int id;
  final String businessName;
  final String email;
  final String phone;
  final String status; // pending | approved | suspended
  final bool verified;
  final String? logoUrl;

  const VendorUser({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.status,
    required this.verified,
    this.logoUrl,
  });

  factory VendorUser.fromJson(Map<String, dynamic> json) {
    return VendorUser(
      id: json['id'] as int,
      businessName: json['business_name'] as String? ?? json['businessName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      verified: json['verified'] as bool? ?? false,
      logoUrl: json['logo_url'] as String?,
    );
  }

  bool get isApproved => status == 'approved';
}
