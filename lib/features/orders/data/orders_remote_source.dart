import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

class OrdersRemoteSource {
  final Dio _dio;
  OrdersRemoteSource(this._dio);

  Future<Map<String, dynamic>> getOrders({int page = 1, String? status}) async {
    final response = await _dio.get(
      ApiEndpoints.orders,
      queryParameters: {
        'page': page,
        'limit': 20,
        'status': status,
      }..removeWhere((_, v) => v == null),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final response = await _dio.get(ApiEndpoints.orderById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStatus(int id, String status) async {
    final response = await _dio.put(
      ApiEndpoints.orderStatus(id),
      data: {'status': status},
    );
    return response.data as Map<String, dynamic>;
  }
}
