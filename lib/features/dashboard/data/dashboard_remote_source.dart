import 'package:dio/dio.dart';

class DashboardRemoteSource {
  final Dio _dio;
  DashboardRemoteSource(this._dio);

  Future<Map<String, dynamic>> getOverview() async {
    final response = await _dio.get('/m/vendor/dashboard');
    return response.data as Map<String, dynamic>;
  }
}
