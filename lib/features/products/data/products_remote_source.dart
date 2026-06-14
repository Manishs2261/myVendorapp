import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProductsRemoteSource {
  final Dio _dio;
  ProductsRemoteSource(this._dio);

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    bool? isDraft,
    int? categoryId,
    String? stockFilter,
    String sortBy = 'recent',
    bool discountOnly = false,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
  }) async {
    final response = await _dio.get(
      '/m/vendor/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        if (search != null && search.isNotEmpty) 'search': search,
        if (isDraft != null) 'is_draft': isDraft,
        if (status != null && isDraft == null) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
        if (stockFilter != null) 'stock_filter': stockFilter,
        if (discountOnly) 'discount_only': true,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minStock != null) 'stock_min': minStock,
        if (maxStock != null) 'stock_max': maxStock,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> publishDraft(int id) async {
    final response = await _dio.post('/m/vendor/products/$id/publish');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await _dio.get('/m/vendor/products/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> body) async {
    final response = await _dio.post('/m/vendor/products', data: body);
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
      '/m/vendor/products',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data; boundary=${formData.boundary}',
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(
      int id, Map<String, dynamic> body) async {
    final response = await _dio.put('/m/vendor/products/$id', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProductMultipart({
    required int id,
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

    final response = await _dio.put(
      '/m/vendor/products/$id',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data; boundary=${formData.boundary}',
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteProduct(int id) => _dio.delete('/m/vendor/products/$id');

  Future<List<dynamic>> getCategories() async {
    final response = await _dio.get('/public/categories');
    return response.data as List<dynamic>;
  }

  Future<void> requestSponsorship(int productId) async {
    await _dio.post('/m/vendor/products/$productId/sponsor-request');
  }
}
