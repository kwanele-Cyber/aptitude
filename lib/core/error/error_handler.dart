import 'app_exception.dart';
import 'package:myapp/core/utils/logger.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    final errStr = error.toString().toLowerCase();
    
    if (errStr.contains('network') || errStr.contains('socket')) {
      return 'Please check your internet connection and try again.';
    }
    
    if (errStr.contains('permission-denied') || errStr.contains('insufficient-permission')) {
      return 'You do not have permission to perform this action.';
    }

    if (errStr.contains('user-not-found')) {
      return 'No account exists with this email address.';
    }

    if (errStr.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }

    if (errStr.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    }

    if (errStr.contains('match-already-exists') || (error is AppException && error.code == ErrorCode.matchAlreadyExists)) {
      return 'You have already connected with this person.';
    }

    if (errStr.contains('match-not-found') || (error is AppException && error.code == ErrorCode.matchNotFound)) {
      return 'Match not found. It may have been updated already.';
    }

    return 'Something went wrong. Please try again later.';
  }

  static void log(dynamic error, [StackTrace? stack]) {
    Log.e('Handled Error: $error', error, stack);
  }
}
