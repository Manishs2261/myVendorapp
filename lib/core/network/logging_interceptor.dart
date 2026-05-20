import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {

  static String generateCurlCommand(RequestOptions options) {
    String curl = 'curl -X ${options.method}';

    // Add headers
    options.headers.forEach((key, value) {
      curl += ' -H "$key: $value"';
    });

    // Handle FormData separately
    if (options.data is FormData) {
      final formData = options.data as FormData;

      for (final field in formData.fields) {
        curl += ' -F "${field.key}=${field.value}"';
      }
      for (final MapEntry<String, MultipartFile> entry in formData.files) {
        final fieldName = entry.key;
        final multipartFile = entry.value;
        final filename = multipartFile.filename ?? 'file';
        curl += ' -F "$fieldName=@<path_to_$filename>;filename=$filename"';
      }
    } else if (options.data != null) {
      curl += ' -d \'${options.data}\'';
    }

    // Add URL
    curl += ' "${options.uri}"';

    return curl;
  }


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curl = _buildCurl(options);
    final headers = _formatMap(options.headers);
    final body = options.data != null ? _prettyJson(options.data) : 'none';

    AppLogger.debug('''
[API] REQUEST =====================================

${options.method} ${options.uri}

HEADERS:
$headers

BODY:
$body


=============================================''');

    debugPrint('CURL-  ${generateCurlCommand(options)}',wrapWidth: 1000);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final headers = _formatMap(
      response.headers.map.map((k, v) => MapEntry(k, v.join(', '))),
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

=============================================''');

    handler.next(response);
  }



  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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

===================================================
''');

    handler.next(err);
  }

  String _buildCurl(RequestOptions options) {
    final sb = StringBuffer('curl -X ${options.method}');
    options.headers.forEach((k, v) => sb.write(" \\\n-H '$k: $v'"));
    if (options.data is FormData) {
      final formData = options.data as FormData;
      for (final field in formData.fields) {
        sb.write(' \\\n-F "${field.key}=${field.value}"');
      }
      for (final file in formData.files) {
        sb.write(' \\\n-F "${file.key}=@<${file.value.filename ?? 'file'}>"');
      }
    } else if (options.data != null) {
      sb.write(" \\\n-d '${jsonEncode(options.data)}'");
    }
    sb.write(" \\\n'${options.uri}'");
    return sb.toString();
  }

  String _formatMap(Map<String, dynamic> map) {
    if (map.isEmpty) return '(empty)';
    return map.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is FormData) {
        final map = <String, dynamic>{};

        // Normal fields
        for (final field in data.fields) {
          map[field.key] = field.value;
        }

        // Files
        for (final file in data.files) {
          map[file.key] = {
            'filename': file.value.filename,
            'contentType': file.value.contentType.toString(),
            'length': file.value.length,
          };
        }

        return const JsonEncoder.withIndent('  ').convert(map);
      }

      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
