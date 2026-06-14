import 'package:dio/dio.dart';

class HelpRemoteSource {
  final Dio _dio;
  HelpRemoteSource(this._dio);

  Future<Map<String, dynamic>> getFeedbackList({
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/m/vendor/help/feedback',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        'type': type,
        'status': status,
      }..removeWhere((_, v) => v == null),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitFeedback(
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post('/m/vendor/help/feedback', data: body);
    return response.data as Map<String, dynamic>;
  }
}
