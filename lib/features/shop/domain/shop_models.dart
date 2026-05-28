class Shop {
  final int id;
  final String businessName;
  final String? shopName;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? contactPhone;
  final String? contactEmail;
  final String? whatsappNumber;
  final String? businessType;
  final String? gstNumber;
  final String? idType;
  final String? idDocumentUrl;
  final List<String> gallery;
  final String status;
  final bool verified;
  final int completionScore;
  final String? openingTime;
  final String? closingTime;
  final List<String> workingDays;

  const Shop({
    required this.id,
    required this.businessName,
    this.shopName,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.latitude,
    this.longitude,
    this.contactPhone,
    this.contactEmail,
    this.whatsappNumber,
    this.businessType,
    this.gstNumber,
    this.idType,
    this.idDocumentUrl,
    this.gallery = const [],
    required this.status,
    required this.verified,
    this.completionScore = 0,
    this.openingTime,
    this.closingTime,
    this.workingDays = const [],
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return Shop(
      id: json['id'] as int,
      businessName: json['business_name'] as String? ?? json['name'] as String? ?? '',
      shopName: json['name'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['postal_code'] as String? ?? json['pincode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      businessType: json['business_type'] as String?,
      gstNumber: json['gst_number'] as String?,
      idType: json['id_type'] as String?,
      idDocumentUrl: json['id_document_url'] as String?,
      gallery: parseStringList(json['gallery']),
      status: json['status'] as String? ?? 'pending',
      verified: json['verified'] as bool? ?? json['is_verified'] as bool? ?? false,
      completionScore: json['completion_score'] as int? ?? 0,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      workingDays: parseStringList(json['working_days']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_name': businessName,
        if (shopName != null) 'name': shopName,
        if (description != null) 'description': description,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (bannerUrl != null) 'banner_url': bannerUrl,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (pincode != null) 'postal_code': pincode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (contactEmail != null) 'contact_email': contactEmail,
        if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
        if (businessType != null) 'business_type': businessType,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (idType != null) 'id_type': idType,
        if (idDocumentUrl != null) 'id_document_url': idDocumentUrl,
        'gallery': gallery,
        'status': status,
        'verified': verified,
        'completion_score': completionScore,
        if (openingTime != null) 'opening_time': openingTime,
        if (closingTime != null) 'closing_time': closingTime,
        'working_days': workingDays,
      };

  Shop copyWith({
    String? logoUrl,
    String? bannerUrl,
    List<String>? gallery,
    String? idDocumentUrl,
  }) {
    return Shop(
      id: id,
      businessName: businessName,
      shopName: shopName,
      description: description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      whatsappNumber: whatsappNumber,
      businessType: businessType,
      gstNumber: gstNumber,
      idType: idType,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      gallery: gallery ?? this.gallery,
      status: status,
      verified: verified,
      completionScore: completionScore,
      openingTime: openingTime,
      closingTime: closingTime,
      workingDays: workingDays,
    );
  }
}
