import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

class ProfileRemoteSource {
  final Dio _dio;
  ProfileRemoteSource(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profileMe);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(ApiEndpoints.profileMe, data: data);
    return response.data as Map<String, dynamic>;
  }
}
