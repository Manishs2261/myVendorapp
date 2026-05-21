import 'package:dio/dio.dart';

class SponsorshipRemoteSource {
  final Dio _dio;
  SponsorshipRemoteSource(this._dio);

  Future<List<dynamic>> getPlans() async {
    final r = await _dio.get('/sponsorships/vendor/plans');
    return r.data as List<dynamic>;
  }

  Future<List<dynamic>> getStatus() async {
    final r = await _dio.get('/sponsorships/vendor/status');
    return r.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> apply(Map<String, dynamic> body) async {
    final r = await _dio.post('/sponsorships/vendor/apply', data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<void> cancel(int sponsorshipId) async {
    await _dio.delete('/sponsorships/vendor/$sponsorshipId/cancel');
  }
}
