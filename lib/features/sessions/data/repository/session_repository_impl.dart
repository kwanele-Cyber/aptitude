import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';
import 'package:myapp/features/admin/domain/repository/admin_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;
  final AdminRepository adminRepository;

  SessionRepositoryImpl({
    required this.remoteDataSource,
    required this.adminRepository,
  });

  @override
  Future<Either<Failure, SessionEntity>> createSession(
      Map<String, dynamic> data) async {
    try {
      final session = await remoteDataSource.createSession(data);
      await adminRepository.logAudit('Created Session', detail: 'Session ID: ${session.id}', severity: 'info', actorRole: 'User');
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> updateSession(
      String id, Map<String, dynamic> data) async {
    try {
      final session = await remoteDataSource.updateSession(id, data);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> cancelSession(
      String id, String? reason) async {
    try {
      final session = await remoteDataSource.cancelSession(id, reason);
      await adminRepository.logAudit('Cancelled Session', detail: 'Session ID: $id | Reason: $reason', severity: 'warning', actorRole: 'User');
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> getSessionById(String id) async {
    try {
      final session = await remoteDataSource.getSessionById(id);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getUserSessions(String userId,
      {SessionStatus? status}) async {
    try {
      final sessions =
          await remoteDataSource.getUserSessions(userId, status: status);
      return Right(sessions);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> joinWaitlist(
      String sessionId, String userId) async {
    try {
      final session =
          await remoteDataSource.joinWaitlist(sessionId, userId);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> leaveWaitlist(
      String sessionId, String userId) async {
    try {
      final session =
          await remoteDataSource.leaveWaitlist(sessionId, userId);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> confirmSession(String id) async {
    try {
      final session = await remoteDataSource.confirmSession(id);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> toggleReminders(
      String id, bool enabled) async {
    try {
      final session = await remoteDataSource.toggleReminders(id, enabled);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> startSession(String id) async {
    try {
      final session = await remoteDataSource.startSession(id);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> completeSession(String id) async {
    try {
      final session = await remoteDataSource.completeSession(id);
      await adminRepository.logAudit('Completed Session', detail: 'Session ID: $id', severity: 'info', actorRole: 'User');
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> generateVerificationCode(
      String sessionId, String userId) async {
    try {
      final session =
          await remoteDataSource.generateVerificationCode(sessionId, userId);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> verifyAttendance(
      String sessionId, String userId, String code) async {
    try {
      final session =
          await remoteDataSource.verifyAttendance(sessionId, userId, code);
      return Right(session);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
