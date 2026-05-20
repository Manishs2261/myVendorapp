import 'package:dio/dio.dart';

class ShopRemoteSource {
  final Dio _dio;
  ShopRemoteSource(this._dio);

  Future<Map<String, dynamic>> getShop() async {
    final response = await _dio.get('/vendor/shop');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateShop(Map<String, dynamic> data) async {
    final response = await _dio.put('/vendor/shop', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getReviewStats() async {
    final response = await _dio.get('/vendor/shop-reviews/stats');
    return response.data as Map<String, dynamic>;
  }
}
