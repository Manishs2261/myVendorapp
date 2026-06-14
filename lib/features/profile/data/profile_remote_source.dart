import 'package:dio/dio.dart';

class ProfileRemoteSource {
  final Dio _dio;
  ProfileRemoteSource(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/m/vendor/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/m/vendor/me', data: data);
    return response.data as Map<String, dynamic>;
  }
}
