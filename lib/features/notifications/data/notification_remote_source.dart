import 'package:dio/dio.dart';

class NotificationRemoteSource {
  final Dio _dio;

  NotificationRemoteSource(this._dio);

  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20, bool unreadOnly = false}) async {
    final response = await _dio.get(
      '/m/vendor/notifications',
      queryParameters: {'page': page, 'limit': limit, 'unread_only': unreadOnly},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> markRead(String id) async {
    await _dio.put('/m/vendor/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/m/vendor/notifications/read-all');
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/m/vendor/notifications/unread-count');
    return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
  }
}
