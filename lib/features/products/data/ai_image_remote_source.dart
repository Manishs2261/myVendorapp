import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class AiModelLoadingException extends ApiException {
  const AiModelLoadingException()
      : super('AI model is warming up. Please retry in ~30 seconds.',
            statusCode: 503);
}

class AiImageRemoteSource {
  final Dio _dio;
  AiImageRemoteSource(this._dio);

  Future<Uint8List> removeBackground(XFile imageFile,
      {CancelToken? cancelToken}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.name,
      ),
    });

    // validateStatus lets 503 through so we can inspect the body ourselves.
    // Override receive timeout to 3 min — AI inference can be slow on cold start.
    final response = await _dio.post<List<int>>(
      ApiEndpoints.aiRemoveBackground,
      data: formData,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status < 600,
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    final status = response.statusCode ?? 0;

    if (status == 503) {
      // Decode the JSON body to confirm it's a model-loading 503.
      try {
        final body = utf8.decode(response.data ?? []);
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['model_loading'] == true) {
          throw const AiModelLoadingException();
        }
      } catch (_) {
        throw const AiModelLoadingException();
      }
    }

    if (status < 200 || status >= 300) {
      throw ServerException('Background removal failed (HTTP $status)',
          statusCode: status);
    }

    return Uint8List.fromList(response.data!);
  }
}
