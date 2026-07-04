import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

class SettingsRemoteSource {
  final Dio _dio;
  SettingsRemoteSource(this._dio);

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post(ApiEndpoints.changePassword, data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<void> sendEmailOtp({String? email}) async {
    await _dio.post(
      ApiEndpoints.verifyEmailSend,
      data: email != null ? {'email': email} : null,
    );
  }

  Future<void> confirmEmailOtp(String otp) async {
    await _dio.post(ApiEndpoints.verifyEmailConfirm, data: {'otp': otp});
  }

  Future<void> sendPhoneOtp({String? phone}) async {
    await _dio.post(
      ApiEndpoints.verifyPhoneSend,
      data: phone != null ? {'phone': phone} : null,
    );
  }

  Future<void> confirmPhoneOtp(String otp) async {
    await _dio.post(ApiEndpoints.verifyPhoneConfirm, data: {'otp': otp});
  }
}
