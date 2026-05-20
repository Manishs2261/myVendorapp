import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(noBoxingByDefault: true,
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 1000,
    ),
    level: Level.debug,
  );

  static bool _isInitialized = false;

  static void initialize() {
    _isInitialized = true;
  }

  static void debug(String message) {
    if (_isInitialized) _logger.d(message);
  }

  static void info(String message) {
    if (_isInitialized) _logger.i(message);
  }

  static void warning(String message) {
    if (_isInitialized) _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isInitialized) {
      _logger.e(message, error: error, stackTrace: stackTrace ?? StackTrace.current);
    }
  }
}
