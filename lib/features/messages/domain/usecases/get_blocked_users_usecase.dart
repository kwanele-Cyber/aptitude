import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class GetBlockedUsersUseCase {
  final MessageRepository repository;

  GetBlockedUsersUseCase(this.repository);

  Stream<Either<Failure, List<String>>> call(String userId) {
    return repository.getBlockedUserIds(userId);
  }
}
