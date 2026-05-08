import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class JoinWaitlistUseCase
    implements UseCase<SessionEntity, JoinWaitlistParams> {
  final SessionRepository repository;

  JoinWaitlistUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      JoinWaitlistParams params) async {
    return repository.joinWaitlist(params.sessionId, params.userId);
  }
}

class JoinWaitlistParams {
  final String sessionId;
  final String userId;

  JoinWaitlistParams({required this.sessionId, required this.userId});
}
