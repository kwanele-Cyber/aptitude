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
  AuthException(super.message, [super.code = ErrorCode.unauthorized, super.original]);
}

class DatabaseException extends AppException {
  DatabaseException(super.message, [super.code = ErrorCode.databaseError, super.original]);
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
  MatchException(super.message, [super.code = ErrorCode.unknown, super.original]);
}

class ChatException extends AppException {
  ChatException(super.message, [super.code = ErrorCode.unknown, super.original]);
}
