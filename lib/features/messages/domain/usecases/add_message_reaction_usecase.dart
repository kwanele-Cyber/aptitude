import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/messages/domain/entity/message_reaction_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class AddMessageReactionParams {
  final String messageId;
  final String userId;
  final String emoji;

  AddMessageReactionParams({
    required this.messageId,
    required this.userId,
    required this.emoji,
  });
}

class AddMessageReactionUsecase
    implements UseCase<void, AddMessageReactionParams> {
  final MessageRepository repository;

  AddMessageReactionUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(AddMessageReactionParams params) {
    return repository.addMessageReaction(
      messageId: params.messageId,
      userId: params.userId,
      emoji: params.emoji,
    );
  }
}
