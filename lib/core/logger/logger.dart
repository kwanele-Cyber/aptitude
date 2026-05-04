enum LogLevel { debug, info, warning, error }

class Logger {
  final String tag;
  static LogLevel _minLevel = LogLevel.debug;

  Logger(this.tag);

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  void debug(String message) {
    _log(LogLevel.debug, message);
  }

  void info(String message) {
    _log(LogLevel.info, message);
  }

  void warning(String message) {
    _log(LogLevel.warning, message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(LogLevel level, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (level.index < _minLevel.index) return;

    final prefix = _prefixFor(level);
    final output = '[$prefix][$tag] $message';

    // ignore: avoid_print
    print(output);

    if (error != null) {
      // ignore: avoid_print
      print('  └─ Error: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('  └─ StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
    }
  }

  String _prefixFor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}
