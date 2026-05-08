import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

abstract class SessionRepository {
  Future<Either<Failure, SessionEntity>> createSession(
      Map<String, dynamic> data);
  Future<Either<Failure, SessionEntity>> updateSession(
      String id, Map<String, dynamic> data);
  Future<Either<Failure, SessionEntity>> cancelSession(
      String id, String? reason);
  Future<Either<Failure, SessionEntity>> getSessionById(String id);
  Future<Either<Failure, List<SessionEntity>>> getUserSessions(String userId,
      {SessionStatus? status});
  Future<Either<Failure, SessionEntity>> joinWaitlist(
      String sessionId, String userId);
  Future<Either<Failure, SessionEntity>> leaveWaitlist(
      String sessionId, String userId);
  Future<Either<Failure, SessionEntity>> confirmSession(String id);
  Future<Either<Failure, SessionEntity>> toggleReminders(
      String id, bool enabled);
  Future<Either<Failure, SessionEntity>> startSession(String id);
  Future<Either<Failure, SessionEntity>> completeSession(String id);
  Future<Either<Failure, SessionEntity>> generateVerificationCode(
      String sessionId, String userId);
  Future<Either<Failure, SessionEntity>> verifyAttendance(
      String sessionId, String userId, String code);
}
