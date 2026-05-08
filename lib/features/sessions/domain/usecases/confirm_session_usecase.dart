import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class ConfirmSessionUseCase
    implements UseCase<SessionEntity, ConfirmSessionParams> {
  final SessionRepository repository;

  ConfirmSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      ConfirmSessionParams params) async {
    return repository.confirmSession(params.id);
  }
}

class ConfirmSessionParams {
  final String id;

  ConfirmSessionParams({required this.id});
}
