import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<Map<String, dynamic>> createProductMultipart({
    required Map<String, dynamic> data,
    required List<XFile> images,
    XFile? video,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(data)));

    for (final img in images) {
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(
          await img.readAsBytes(),
          filename: img.name,
        ),
      ));
    }

    if (video != null) {
      formData.files.add(MapEntry(
        'video',
        MultipartFile.fromBytes(
          await video.readAsBytes(),
          filename: video.name,
        ),
      ));
    }

    final response = await _dio.post(
      '/vendor/products',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data; boundary=${formData.boundary}',
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(
      int id, Map<String, dynamic> body) async {
    final response = await _dio.put('/vendor/products/$id', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteProduct(int id) => _dio.delete('/vendor/products/$id');

  Future<List<dynamic>> getCategories() async {
    final response = await _dio.get('/public/categories');
    return response.data as List<dynamic>;
  }

}
