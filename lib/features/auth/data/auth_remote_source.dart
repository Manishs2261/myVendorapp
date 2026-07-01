import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

class AuthRemoteSource {
  final Dio _dio;

  AuthRemoteSource(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiateRegister(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.registerInitiate, data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completeRegister(String email, String otp) async {
    final response = await _dio.post(
      ApiEndpoints.registerComplete,
      data: {'email': email, 'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> resendRegisterOtp(String email) async {
    await _dio.post(ApiEndpoints.registerResend, data: {'email': email});
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get(ApiEndpoints.me);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<String> verifyResetOtp(String email, String otp) async {
    final response = await _dio.post(
      ApiEndpoints.verifyResetOtp,
      data: {'email': email, 'otp': otp},
    );
    return response.data['reset_token'] as String;
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'new_password': newPassword},
    );
  }

  Future<void> saveFcmToken(String token, {String deviceType = 'mobile', String platform = 'android'}) async {
    try {
      await _dio.post(
        ApiEndpoints.fcmToken,
        data: {'token': token, 'device_type': deviceType, 'platform': platform},
      );
    } catch (_) {
      // Non-fatal — swallow silently
    }
  }
}
