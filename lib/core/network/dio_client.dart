import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'api_exception.dart';
import 'logging_interceptor.dart';

class DioClient {
  static Dio create(SecureStorageService storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storage, dio),
      LoggingInterceptor(),
      _errorInterceptor(),
    ]);

    return dio;
  }

  static Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (err, handler,) {
        if (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout) {
          handler.next(
            DioException(
              requestOptions: err.requestOptions,
              error: const NetworkException(),
              type: err.type,
            ),
          );
          return;
        }

        final status = err.response?.statusCode;
        final data = err.response?.data;
        final message = (data is Map
                    ? (data['detail'] as String? ?? data['message'] as String?)
                    : null) ??
                (err.message?.isNotEmpty == true ? err.message : null) ??
                'Something went wrong';

        if (status == 401) {
          handler.next(
            DioException(
              requestOptions: err.requestOptions,
              error: UnauthorizedException(message),
              response: err.response,
              type: err.type,
            ),
          );
          return;
        }

        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(message, statusCode: status),
            response: err.response,
            type: err.type,
          ),
        );
      },
    );
  }
}
