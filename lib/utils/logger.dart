import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _appName = 'Calistreet';

  static void _log(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag.padRight(20);

    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] [$levelStr] [$tagStr] $message');

    if (error != null) {
      buffer.writeln('  Error: $error');
    }

    if (stackTrace != null) {
      buffer.writeln('  StackTrace: $stackTrace');
    }

    if (extra != null && extra.isNotEmpty) {
      buffer.writeln('  Extra: $extra');
    }

    // usando developer.log q é mais apropriado para Flutter
    developer.log(
      buffer.toString(),
      name: _appName,
      level: _getLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 700; // Fine
      case LogLevel.info:
        return 800; // Info
      case LogLevel.warning:
        return 900; // Warning
      case LogLevel.error:
        return 1000; // Severe
    }
  }

  static void debug(String tag, String message, {Map<String, dynamic>? extra}) {
    _log(LogLevel.debug, tag, message, extra: extra);
  }

  static void info(String tag, String message, {Map<String, dynamic>? extra}) {
    _log(LogLevel.info, tag, message, extra: extra);
  }

  static void warning(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.warning,
      tag,
      message,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  static void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.error,
      tag,
      message,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }
}
