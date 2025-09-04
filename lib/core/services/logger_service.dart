import 'dart:developer' as developer;

class LoggerService {
  static const String _tag = 'MoneyApp';
  
  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800,
    );
  }
  
  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900,
    );
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void debug(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 700,
    );
  }
}