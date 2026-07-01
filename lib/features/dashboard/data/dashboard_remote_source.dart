import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

class DashboardRemoteSource {
  final Dio _dio;
  DashboardRemoteSource(this._dio);

  Future<Map<String, dynamic>> getOverview() async {
    final response = await _dio.get(ApiEndpoints.dashboard);
    return response.data as Map<String, dynamic>;
  }
}
