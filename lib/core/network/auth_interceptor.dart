import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  bool _isRefreshing = false;
  final _pendingRequests = <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) throw const UnauthorizedException();

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String? ?? refreshToken;

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Retry original request
      final retried = await _retry(err.requestOptions, newAccess);
      handler.resolve(retried);

      // Retry any queued requests
      for (final pending in _pendingRequests) {
        try {
          final r = await _retry(pending.options, newAccess);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.next(err);
        }
      }
    } catch (e) {
      // Only clear tokens on genuine auth failure (invalid/expired refresh token).
      // Network errors and timeouts must not wipe tokens — user is just offline.
      final bool isAuthFailure = e is UnauthorizedException ||
          (e is DioException &&
              (e.response?.statusCode == 401 ||
                  e.response?.statusCode == 403));
      if (isAuthFailure) {
        await _storage.clearAll();
      }
      for (final pending in _pendingRequests) {
        pending.handler.next(err);
      }
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    return _dio.fetch(
      options
        ..headers['Authorization'] = 'Bearer $token',
    );
  }
}
