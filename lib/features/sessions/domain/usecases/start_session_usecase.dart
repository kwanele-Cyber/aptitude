import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class StartSessionUseCase
    implements UseCase<SessionEntity, StartSessionParams> {
  final SessionRepository repository;

  StartSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      StartSessionParams params) async {
    return repository.startSession(params.id);
  }
}

class StartSessionParams {
  final String id;

  StartSessionParams({required this.id});
}
