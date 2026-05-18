import 'auth_models.dart';

abstract class IAuthRepository {
  Future<void> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<VendorUser?> getMe();
  Future<void> logout();
  Future<String?> getStoredToken();
}
