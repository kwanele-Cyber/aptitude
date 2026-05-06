import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class SendRoomMessageUseCase implements UseCase<void, SendRoomMessageParams> {
  final MessageRepository repository;

  SendRoomMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendRoomMessageParams params) {
    return repository.sendRoomMessage(params.roomId, params.message);
  }
}

class SendRoomMessageParams {
  final String roomId;
  final MessageEntity message;

  const SendRoomMessageParams({
    required this.roomId,
    required this.message,
  });
}
