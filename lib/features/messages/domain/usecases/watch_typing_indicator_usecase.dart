import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class WatchTypingIndicatorParams {
  final String conversationId;

  WatchTypingIndicatorParams({required this.conversationId});
}

// class WatchTypingIndicatorUsecase {
//   final MessageRepository repository;

//   WatchTypingIndicatorUsecase(Object object, {required this.repository});

//   Stream<Either<Failure, Map<String, bool>>> call(
//       WatchTypingIndicatorParams params) {
//     return repository.watchTypingIndicator(conversationId: params.conversationId);
//   }
// }

class WatchTypingIndicatorUsecase {
  final MessageRepository repository;

  WatchTypingIndicatorUsecase(this.repository);

  Stream<Either<Failure, Map<String, bool>>> call(
      WatchTypingIndicatorParams params) {
    return repository.watchTypingIndicator(conversationId: params.conversationId);
  }
}

