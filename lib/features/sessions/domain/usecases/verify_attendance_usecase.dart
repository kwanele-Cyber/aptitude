import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class VerifyAttendanceUseCase
    implements UseCase<SessionEntity, VerifyAttendanceParams> {
  final SessionRepository repository;

  VerifyAttendanceUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      VerifyAttendanceParams params) async {
    return repository.verifyAttendance(
        params.sessionId, params.userId, params.code);
  }
}

class VerifyAttendanceParams {
  final String sessionId;
  final String userId;
  final String code;

  VerifyAttendanceParams({
    required this.sessionId,
    required this.userId,
    required this.code,
  });
}
