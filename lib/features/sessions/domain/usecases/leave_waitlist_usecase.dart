import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class LeaveWaitlistUseCase
    implements UseCase<SessionEntity, LeaveWaitlistParams> {
  final SessionRepository repository;

  LeaveWaitlistUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      LeaveWaitlistParams params) async {
    return repository.leaveWaitlist(params.sessionId, params.userId);
  }
}

class LeaveWaitlistParams {
  final String sessionId;
  final String userId;

  LeaveWaitlistParams({required this.sessionId, required this.userId});
}
