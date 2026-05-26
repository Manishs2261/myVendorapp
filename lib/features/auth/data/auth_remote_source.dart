import 'package:dio/dio.dart';

class AuthRemoteSource {
  final Dio _dio;

  AuthRemoteSource(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login/vendor',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/register/vendor', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> saveFcmToken(String token, {String deviceType = 'mobile', String platform = 'android'}) async {
    try {
      await _dio.post(
        '/auth/fcm-token',
        data: {'token': token, 'device_type': deviceType, 'platform': platform},
      );
    } catch (_) {
      // Non-fatal — swallow silently
    }
  }
}
