import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curl = _buildCurl(options);
    final headers = _formatMap(options.headers);
    final body = options.data != null ? _prettyJson(options.data) : 'none';

    log('''
REQUEST =====================================

${options.method} ${options.uri}

HEADERS:
$headers

BODY:
$body

cURL:
$curl

=============================================
''', name: 'API');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final headers = _formatMap(
      response.headers.map.map((k, v) => MapEntry(k, v.join(', '))),
    );

    final body = _prettyJson(response.data);

    log('''
RESPONSE ====================================

${response.statusCode} ${response.requestOptions.method}
${response.requestOptions.uri}

HEADERS:
$headers

BODY:
$body

=============================================
''', name: 'API');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final body = _prettyJson(err.response?.data);

    log('''
ERROR =======================================

${err.response?.statusCode ?? 'N/A'}
${err.requestOptions.method}
${err.requestOptions.uri}

MESSAGE:
${err.message}

BODY:
$body

=============================================
''', name: 'API');

    handler.next(err);
  }

  String _buildCurl(RequestOptions options) {
    final sb = StringBuffer('curl -X ${options.method}');

    options.headers.forEach((k, v) {
      sb.write(" \\\n-H '$k: $v'");
    });

    if (options.data != null) {
      final encoded = jsonEncode(options.data);
      sb.write(" \\\n-d '$encoded'");
    }

    sb.write(" \\\n'${options.uri}'");

    return sb.toString();
  }

  String _formatMap(Map<String, dynamic> map) {
    if (map.isEmpty) return '(empty)';

    return map.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  String _prettyJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}