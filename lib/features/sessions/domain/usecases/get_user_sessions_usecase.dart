import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class GetUserSessionsUseCase
    implements UseCase<List<SessionEntity>, GetUserSessionsParams> {
  final SessionRepository repository;

  GetUserSessionsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<SessionEntity>>> call(
      GetUserSessionsParams params) async {
    return repository.getUserSessions(params.userId, status: params.status);
  }
}

class GetUserSessionsParams {
  final String userId;
  final SessionStatus? status;

  GetUserSessionsParams({required this.userId, this.status});
}
