import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class UnblockUserUseCase {
  final MessageRepository repository;

  UnblockUserUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String currentUserId, String blockedUserId) {
    return repository.unblockUser(currentUserId, blockedUserId);
  }
}
