import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) => 
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void f(String message, [dynamic error, StackTrace? stackTrace]) => 
      _logger.f(message, error: error, stackTrace: stackTrace);
}
