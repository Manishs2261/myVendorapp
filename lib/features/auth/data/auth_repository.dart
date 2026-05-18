import '../../auth/domain/auth_models.dart';
import '../../auth/domain/i_auth_repository.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_remote_source.dart';

class AuthRepository implements IAuthRepository {
  final AuthRemoteSource _remote;
  final SecureStorageService _storage;

  AuthRepository(this._remote, this._storage);

  @override
  Future<void> login(LoginRequest request) async {
    final data = await _remote.login(request.email, request.password);
    final role = data['role'] as String? ?? '';
    if (role.toUpperCase() != 'VENDOR') {
      throw const ApiException('Access denied. Vendor account required.');
    }
    await _storage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  @override
  Future<void> register(RegisterRequest request) async {
    final data = await _remote.register(request.toJson());
    await _storage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  @override
  Future<VendorUser?> getMe() async {
    final data = await _remote.getMe();
    return VendorUser.fromJson(data);
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<String?> getStoredToken() => _storage.getAccessToken();
}
