import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String userId1, String userId2) {
    return repository.getMessages(userId1, userId2);
  }
}