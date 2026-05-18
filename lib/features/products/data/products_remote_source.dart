import 'package:dio/dio.dart';

class ProductsRemoteSource {
  final Dio _dio;
  ProductsRemoteSource(this._dio);

  Future<Map<String, dynamic>> getProducts({int page = 1, String? status}) async {
    final response = await _dio.get(
      '/vendor/products',
      queryParameters: {
        'page': page,
        'limit': 20,
        'status': status,
      }..removeWhere((_, v) => v == null),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await _dio.get('/vendor/products/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> body) async {
    final response = await _dio.post('/vendor/products', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(
      int id, Map<String, dynamic> body) async {
    final response = await _dio.put('/vendor/products/$id', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteProduct(int id) =>
      _dio.delete('/vendor/products/$id');
}
