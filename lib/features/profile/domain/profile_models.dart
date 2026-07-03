
import 'dart:convert';

VendorProfile welcomeFromJson(String str) => VendorProfile.fromJson(json.decode(str));

String welcomeToJson(VendorProfile data) => json.encode(data.toJson());

class VendorProfile {
  int? id;
  dynamic firebaseUid;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? status;
  dynamic avatarUrl;
  dynamic gender;
  dynamic dateOfBirth;
  dynamic alternatePhone;
  dynamic pincode;
  dynamic city;
  dynamic state;
  dynamic language;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  String? createdAt;

  VendorProfile({
    this.id,
    this.firebaseUid,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.status,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.alternatePhone,
    this.pincode,
    this.city,
    this.state,
    this.language,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.createdAt,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) => VendorProfile(
    id: json["id"],
    firebaseUid: json["firebase_uid"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    role: json["role"],
    status: json["status"],
    avatarUrl: json["avatar_url"],
    gender: json["gender"],
    dateOfBirth: json["date_of_birth"],
    alternatePhone: json["alternate_phone"],
    pincode: json["pincode"],
    city: json["city"],
    state: json["state"],
    language: json["language"],
    isEmailVerified: json["is_email_verified"],
    isPhoneVerified: json["is_phone_verified"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firebase_uid": firebaseUid,
    "name": name,
    "email": email,
    "phone": phone,
    "role": role,
    "status": status,
    "avatar_url": avatarUrl,
    "gender": gender,
    "date_of_birth": dateOfBirth,
    "alternate_phone": alternatePhone,
    "pincode": pincode,
    "city": city,
    "state": state,
    "language": language,
    "is_email_verified": isEmailVerified,
    "is_phone_verified": isPhoneVerified,
    "created_at": createdAt,
  };
}
