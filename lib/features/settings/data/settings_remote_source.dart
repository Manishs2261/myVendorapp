import 'package:dio/dio.dart';

class SettingsRemoteSource {
  final Dio _dio;
  SettingsRemoteSource(this._dio);

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post('/auth/change-password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<void> sendEmailOtp({String? email}) async {
    await _dio.post(
      '/auth/verify/email/send',
      data: email != null ? {'email': email} : null,
    );
  }

  Future<void> confirmEmailOtp(String otp) async {
    await _dio.post('/auth/verify/email/confirm', data: {'otp': otp});
  }

  Future<void> sendPhoneOtp() async {
    await _dio.post('/auth/verify/phone/send');
  }

  Future<void> confirmPhoneOtp(String otp) async {
    await _dio.post('/auth/verify/phone/confirm', data: {'otp': otp});
  }
}
