import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ShopRemoteSource {
  final Dio _dio;
  ShopRemoteSource(this._dio);

  Future<Map<String, dynamic>> getShop() async {
    final response = await _dio.get('/m/vendor/shop');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateShop(Map<String, dynamic> data) async {
    final response = await _dio.put('/m/vendor/shop', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getReviewStats() async {
    final response = await _dio.get('/m/vendor/shop-reviews/stats');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getShopReviews({
    int page = 1,
    int limit = 20,
    String? search,
    int? rating,
    String sort = 'latest',
  }) async {
    final response = await _dio.get(
      '/m/vendor/shop-reviews',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (rating != null) 'rating': rating,
        'sort': sort,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<String> uploadLogo(XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
      ),
    });
    final response = await _dio.post('/m/vendor/shop/logo', data: formData);
    return (response.data as Map<String, dynamic>)['url'] as String;
  }

  Future<String> uploadBanner(XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
      ),
    });
    final response = await _dio.post('/m/vendor/shop/banner', data: formData);
    return (response.data as Map<String, dynamic>)['url'] as String;
  }

  Future<List<String>> uploadGallery(List<XFile> files) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(MapEntry(
        'files',
        MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        ),
      ));
    }
    final response = await _dio.post('/m/vendor/shop/gallery', data: formData);
    final urls = (response.data as Map<String, dynamic>)['urls'] as List;
    return urls.map((e) => e.toString()).toList();
  }

  Future<Map<String, dynamic>> getProductReviewStats() async {
    final response = await _dio.get('/m/vendor/reviews/stats');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProductReviews({
    int page = 1,
    int limit = 20,
    String? search,
    int? rating,
    String sort = 'latest',
  }) async {
    final response = await _dio.get(
      '/m/vendor/reviews',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (rating != null) 'rating': rating,
        'sort': sort,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> removeGalleryImage(String url) async {
    await _dio.delete('/m/vendor/shop/gallery', data: {'url': url});
  }

  Future<String> uploadIdDocument(XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
      ),
    });
    final response = await _dio.post('/m/vendor/shop/id-document', data: formData);
    return (response.data as Map<String, dynamic>)['url'] as String;
  }
}
