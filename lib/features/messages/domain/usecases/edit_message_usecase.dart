import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class EditMessageParams {
  final String messageId;
  final String newContent;
  final String roomId;

  EditMessageParams({
    required this.messageId,
    required this.newContent,
    required this.roomId,
  });
}

class EditMessageUsecase implements UseCase<void, EditMessageParams> {
  final MessageRepository repository;

  EditMessageUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(EditMessageParams params) {
    return repository.editMessage(
      messageId: params.messageId,
      newContent: params.newContent,
      roomId: params.roomId,
    );
  }
}
