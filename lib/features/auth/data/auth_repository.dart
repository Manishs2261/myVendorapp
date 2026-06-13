import 'package:dio/dio.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/i_auth_repository.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/json_parser.dart';
import 'auth_remote_source.dart';

class AuthRepository implements IAuthRepository {
  final AuthRemoteSource _remote;
  final SecureStorageService _storage;

  AuthRepository(this._remote, this._storage);

  Never _unwrapDio(DioException e) {
    final inner = e.error;
    if (inner is ApiException) throw inner;
    final msg = e.response?.data?['detail'] as String? ??
        e.response?.data?['message'] as String? ??
        e.message ??
        'Request failed';
    throw ServerException(msg, statusCode: e.response?.statusCode);
  }

  @override
  Future<void> login(LoginRequest request) async {
    try {
      final data = await _remote.login(request.email, request.password);
      final role = data['role'] as String? ?? '';
      if (role.toUpperCase() != 'VENDOR') {
        throw const ApiException('Access denied. Vendor account required.');
      }
      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    } on DioException catch (e) {
      _unwrapDio(e);
    }
  }

  @override
  Future<String> initiateRegistration(RegisterRequest request) async {
    try {
      final data = await _remote.initiateRegister(request.toJson());
      return data['message'] as String? ?? 'OTP sent to your email';
    } on DioException catch (e) {
      _unwrapDio(e);
    }
  }

  @override
  Future<void> completeRegistration(String email, String otp) async {
    try {
      final data = await _remote.completeRegister(email, otp);
      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    } on DioException catch (e) {
      _unwrapDio(e);
    }
  }

  @override
  Future<VendorUser?> getMe() async {
    final data = await _remote.getMe();
    return parseJson('VendorUser', data, VendorUser.fromJson);
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<String?> getStoredToken() => _storage.getAccessToken();
}
