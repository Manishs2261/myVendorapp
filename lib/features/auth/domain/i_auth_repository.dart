import 'auth_models.dart';

abstract class IAuthRepository {
  Future<void> login(LoginRequest request);
  Future<String> initiateRegistration(RegisterRequest request);
  Future<void> completeRegistration(String email, String otp);
  Future<VendorUser?> getMe();
  Future<void> logout();
  Future<String?> getStoredToken();
}
