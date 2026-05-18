import 'profile_models.dart';

abstract class IProfileRepository {
  Future<VendorProfile> getProfile();
  Future<VendorProfile> updateProfile(Map<String, dynamic> data);
}
