import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'api_exception.dart';

class DioClient {
  static const baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator localhost

  static Dio create(SecureStorageService storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storage, dio),
      _errorInterceptor(),
    ]);

    return dio;
  }

  static Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (err, handler) {
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
        final message =
            err.response?.data?['message'] as String? ?? err.message ?? 'Unknown error';

        if (status == 401) {
          handler.next(
            DioException(
              requestOptions: err.requestOptions,
              error: const UnauthorizedException(),
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
