abstract class CustomException implements Exception {
  final String message;
  final String? code;

  CustomException(this.message, [this.code]);

  @override
  String toString() => "[$code] $message";
}

class AuthException extends CustomException {
  AuthException(super.message, [super.code]);
}

class DatabaseException extends CustomException {
  DatabaseException(super.message, [super.code]);
}

class ValidationException extends CustomException {
  ValidationException(String message) : super(message, "validation-error");
}

class NetworkException extends CustomException {
  NetworkException(String message) : super(message, "network-error");
}
