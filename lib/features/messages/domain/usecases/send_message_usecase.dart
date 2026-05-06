import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  final MessageRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendMessageParams params) async {
    return repository.sendMessage(params.message);
  }
}

class SendMessageParams {
  final MessageEntity message;

  const SendMessageParams({required this.message});
}