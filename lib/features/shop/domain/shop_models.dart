// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Shop welcomeFromJson(String str) => Shop.fromJson(json.decode(str));

String welcomeToJson(Shop data) => json.encode(data.toJson());

class Shop {
  int? id;
  int? vendorId;
  String? name;
  String? description;
  String? address;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? postalCode;
  double? latitude;
  double? longitude;
  String? logoUrl;
  String? bannerUrl;
  List<String>? gallery;
  String? status;
  String? openingTime;
  String? closingTime;
  List<String>? workingDays;
  String? contactPhone;
  String? contactEmail;
  String? whatsappNumber;
  String? businessType;
  String? idType;
  String? idDocumentUrl;
  String? gstNumber;
  bool? isVerified;
  bool? verificationRequested;
  int? completionScore;

  Shop({
    this.id,
    this.vendorId,
    this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.bannerUrl,
    this.gallery,
    this.status,
    this.openingTime,
    this.closingTime,
    this.workingDays,
    this.contactPhone,
    this.contactEmail,
    this.whatsappNumber,
    this.businessType,
    this.idType,
    this.idDocumentUrl,
    this.gstNumber,
    this.isVerified,
    this.verificationRequested,
    this.completionScore,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    vendorId: json["vendor_id"],
    name: json["name"],
    description: json["description"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    pincode: json["pincode"],
    postalCode: json["postal_code"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    logoUrl: json["logo_url"],
    bannerUrl: json["banner_url"],
    gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x)),
    status: json["status"],
    openingTime: json["opening_time"],
    closingTime: json["closing_time"],
    workingDays: json["working_days"] == null ? [] : List<String>.from(json["working_days"]!.map((x) => x)),
    contactPhone: json["contact_phone"],
    contactEmail: json["contact_email"],
    whatsappNumber: json["whatsapp_number"],
    businessType: json["business_type"],
    idType: json["id_type"],
    idDocumentUrl: json["id_document_url"],
    gstNumber: json["gst_number"],
    isVerified: json["is_verified"],
    verificationRequested: json["verification_requested"],
    completionScore: json["completion_score"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "name": name,
    "description": description,
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "pincode": pincode,
    "postal_code": postalCode,
    "latitude": latitude,
    "longitude": longitude,
    "logo_url": logoUrl,
    "banner_url": bannerUrl,
    "gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
    "status": status,
    "opening_time": openingTime,
    "closing_time": closingTime,
    "working_days": workingDays == null ? [] : List<dynamic>.from(workingDays!.map((x) => x)),
    "contact_phone": contactPhone,
    "contact_email": contactEmail,
    "whatsapp_number": whatsappNumber,
    "business_type": businessType,
    "id_type": idType,
    "id_document_url": idDocumentUrl,
    "gst_number": gstNumber,
    "is_verified": isVerified,
    "verification_requested": verificationRequested,
    "completion_score": completionScore,
  };

  Shop copyWith({
    int? id,
    int? vendorId,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? bannerUrl,
    List<String>? gallery,
    String? status,
    String? openingTime,
    String? closingTime,
    List<String>? workingDays,
    String? contactPhone,
    String? contactEmail,
    String? whatsappNumber,
    String? businessType,
    String? idType,
    String? idDocumentUrl,
    String? gstNumber,
    bool? isVerified,
    bool? verificationRequested,
    int? completionScore,
  }) {
    return Shop(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      gallery: gallery ?? this.gallery,
      status: status ?? this.status,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      workingDays: workingDays ?? this.workingDays,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      businessType: businessType ?? this.businessType,
      idType: idType ?? this.idType,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      gstNumber: gstNumber ?? this.gstNumber,
      isVerified: isVerified ?? this.isVerified,
      verificationRequested: verificationRequested ?? this.verificationRequested,
      completionScore: completionScore ?? this.completionScore,
    );
  }
}
