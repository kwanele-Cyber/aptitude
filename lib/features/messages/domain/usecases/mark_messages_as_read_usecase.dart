import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class MarkMessagesAsReadUseCase implements UseCase<void, MarkMessagesAsReadParams> {
  final MessageRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesAsReadParams params) async {
    return repository.markMessagesAsRead(params.userId1, params.userId2);
  }
}

class MarkMessagesAsReadParams {
  final String userId1;
  final String userId2;

  const MarkMessagesAsReadParams({required this.userId1, required this.userId2});
}