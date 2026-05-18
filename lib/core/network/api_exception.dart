class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(
      [super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}
