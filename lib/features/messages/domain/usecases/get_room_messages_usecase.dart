import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class GetRoomMessagesUseCase {
  final MessageRepository repository;

  GetRoomMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String roomId) {
    return repository.getRoomMessages(roomId);
  }
}
