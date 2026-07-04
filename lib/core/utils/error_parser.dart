import 'package:dio/dio.dart';

/// Extracts a user-friendly error message from an exception/error object.
String extractError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
  }

  final str = e.toString();
  final match = RegExp(r'"detail":\s*"([^"]+)"').firstMatch(str);
  if (match != null) return match.group(1)!;

  final match2 = RegExp(r'detail: (.+)$', multiLine: true).firstMatch(str);
  if (match2 != null) return match2.group(1)!.trim();

  return str.length > 120 ? '${str.substring(0, 120)}...' : str;
}
