import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class CompleteSessionUseCase
    implements UseCase<SessionEntity, CompleteSessionParams> {
  final SessionRepository repository;

  CompleteSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      CompleteSessionParams params) async {
    return repository.completeSession(params.id);
  }
}

class CompleteSessionParams {
  final String id;

  CompleteSessionParams({required this.id});
}
