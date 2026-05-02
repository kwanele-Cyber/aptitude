enum ErrorCode {
  unknown,
  unauthorized,
  networkError,
  databaseError,
  invalidInput,
  notFound,
  permissionDenied,
  accountExists,
  weakPassword,
  matchAlreadyExists,
  matchNotFound,
  channelNotFound,
  messageNotFound,
  userBlocked,
  alreadyBlocked,
  emptyMessage,
  messageTooLong,
  pushTokenMissing,
  reportLimitExceeded,
  selfChatNotAllowed,
}

abstract class AppException implements Exception {
  final String message;
  final ErrorCode code;
  final dynamic originalError;

  AppException(this.message, this.code, [this.originalError]);

  @override
  String toString() => 'AppException: [$code] $message';
}

class AuthException extends AppException {
  AuthException(String message, [ErrorCode code = ErrorCode.unauthorized, dynamic original])
      : super(message, code, original);
}

class DatabaseException extends AppException {
  DatabaseException(String message, [ErrorCode code = ErrorCode.databaseError, dynamic original])
      : super(message, code, original);
}

class ValidationException extends AppException {
  ValidationException(String message, [dynamic original])
      : super(message, ErrorCode.invalidInput, original);
}

class NetworkException extends AppException {
  NetworkException(String message, [dynamic original])
      : super(message, ErrorCode.networkError, original);
}

class MatchException extends AppException {
  MatchException(String message, [ErrorCode code = ErrorCode.unknown, dynamic original])
      : super(message, code, original);
}

class ChatException extends AppException {
  ChatException(String message, [ErrorCode code = ErrorCode.unknown, dynamic original])
      : super(message, code, original);
}
