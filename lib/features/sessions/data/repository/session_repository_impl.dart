import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;

  SessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SessionEntity>> createSession(
      Map<String, dynamic> data) async {
    try {
      final session = await remoteDataSource.createSession(data);
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
