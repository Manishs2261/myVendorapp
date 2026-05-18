class ApiError {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'Something went wrong',
      statusCode: json['statusCode'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}
