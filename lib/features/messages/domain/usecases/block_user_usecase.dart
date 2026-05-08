import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class BlockUserUseCase {
  final MessageRepository repository;

  BlockUserUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String currentUserId, String blockedUserId, String blockedUserName) {
    return repository.blockUser(currentUserId, blockedUserId, blockedUserName);
  }
}
