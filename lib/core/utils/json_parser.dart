import 'app_logger.dart';

/// Wraps a [fromJson] call with detailed error logging.
/// On parse failure, logs the model name, raw JSON, and the error before rethrowing.
T parseJson<T>(
  String modelName,
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) fromJson,
) {
  try {
    return fromJson(json);
  } catch (e, stack) {
    AppLogger.error(
      '[PARSE ERROR] ==============================\n'
      'Model  : $modelName\n'
      'JSON   : $json\n'
      '========================================',
      e,
      stack,
    );
    rethrow;
  }
}

/// Same as [parseJson] but for list items — logs the index and item on failure.
List<T> parseJsonList<T>(
  String modelName,
  List<dynamic> list,
  T Function(Map<String, dynamic>) fromJson,
) {
  final result = <T>[];
  for (var i = 0; i < list.length; i++) {
    try {
      result.add(fromJson(list[i] as Map<String, dynamic>));
    } catch (e, stack) {
      AppLogger.error(
        '[PARSE ERROR] ==============================\n'
        'Model  : $modelName (index $i)\n'
        'JSON   : ${list[i]}\n'
        '========================================',
        e,
        stack,
      );
      rethrow;
    }
  }
  return result;
}
