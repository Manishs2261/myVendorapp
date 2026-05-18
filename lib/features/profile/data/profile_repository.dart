import '../domain/i_profile_repository.dart';
import '../domain/profile_models.dart';
import 'profile_remote_source.dart';

class ProfileRepository implements IProfileRepository {
  final ProfileRemoteSource _remote;
  ProfileRepository(this._remote);

  @override
  Future<VendorProfile> getProfile() async {
    final data = await _remote.getProfile();
    return VendorProfile.fromJson(data);
  }

  @override
  Future<VendorProfile> updateProfile(Map<String, dynamic> data) async {
    final updated = await _remote.updateProfile(data);
    return VendorProfile.fromJson(updated);
  }
}
