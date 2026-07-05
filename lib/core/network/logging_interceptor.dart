import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    final headers = _formatMap(options.headers);
    final body = options.data != null ? _prettyJson(options.data) : 'none';

    AppLogger.debug('''
[API] REQUEST =====================================

${options.method} ${options.uri}

HEADERS:
$headers

BODY:
$body

=============================================
''');

    developer.log(
      '''
================== CURL ==================

${_buildCurl(options)}

==========================================
''',
      name: 'API CURL',
    );

    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    final headers = _formatMap(
      response.headers.map.map(
            (k, v) => MapEntry(k, v.join(', ')),
      ),
    );

    final body = _prettyJson(response.data);

    AppLogger.info('''
[API] RESPONSE ====================================

${response.statusCode} ${response.requestOptions.method}
${response.requestOptions.uri}

HEADERS:
$headers

BODY:
$body

=============================================
''');

    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    final requestHeaders = _formatMap(err.requestOptions.headers);

    final requestBody = err.requestOptions.data != null
        ? _prettyJson(err.requestOptions.data)
        : 'none';

    final responseHeaders = err.response != null
        ? _formatMap(
      err.response!.headers.map.map(
            (k, v) => MapEntry(k, v.join(', ')),
      ),
    )
        : 'none';

    final responseBody = _prettyJson(err.response?.data);

    AppLogger.error('''
[API] ERROR =======================================

${err.response?.statusCode ?? 'N/A'}
${err.requestOptions.method}
${err.requestOptions.uri}

REQUEST HEADERS:
$requestHeaders

REQUEST BODY:
$requestBody

RESPONSE HEADERS:
$responseHeaders

RESPONSE BODY:
$responseBody

MESSAGE:
${err.message}

CURL:

${_buildCurl(err.requestOptions)}

===================================================
''');

    handler.next(err);
  }

  String _buildCurl(RequestOptions options) {
    final sb = StringBuffer();

    sb.write('curl -X ${options.method}');

    options.headers.forEach((key, value) {
      sb.write(' -H "$key: $value"');
    });

    final data = options.data;

    if (data != null) {
      if (data is FormData) {
        for (final field in data.fields) {
          sb.write(' -F "${field.key}=${field.value}"');
        }

        for (final file in data.files) {
          final filename = file.value.filename ?? 'file';
          sb.write(
              ' -F "${file.key}=@<path_to_$filename>;filename=$filename"');
        }
      } else if (data is String) {
        sb.write(" -d '$data'");
      } else {
        sb.write(" -d '${jsonEncode(data)}'");
      }
    }

    sb.write(' "${options.uri}"');

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
      if (data == null) return 'null';

      if (data is FormData) {
        final map = <String, dynamic>{};

        for (final field in data.fields) {
          map[field.key] = field.value;
        }

        for (final file in data.files) {
          map[file.key] = {
            'filename': file.value.filename,
            'contentType': file.value.contentType?.toString(),
            'length': file.value.length,
          };
        }

        return const JsonEncoder.withIndent('  ').convert(map);
      }

      if (data is String) {
        try {
          return const JsonEncoder.withIndent('  ')
              .convert(jsonDecode(data));
        } catch (_) {
          return data;
        }
      }

      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}