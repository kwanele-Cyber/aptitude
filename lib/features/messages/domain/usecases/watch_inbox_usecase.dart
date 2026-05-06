import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/entity/inbox_conversation_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class WatchInboxUseCase {
  final MessageRepository repository;

  WatchInboxUseCase(this.repository);

  Stream<Either<Failure, List<InboxConversationEntity>>> call(String userId) {
    return repository.watchInbox(userId);
  }
}
