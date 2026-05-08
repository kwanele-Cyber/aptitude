import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_note_remote_datasource.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';

class SessionNoteRepositoryImpl implements SessionNoteRepository {
  final SessionNoteRemoteDataSource remoteDataSource;

  SessionNoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SessionNoteEntity>> getSessionNotes(
      String sessionId) async {
    try {
      final notes = await remoteDataSource.getSessionNotes(sessionId);
      return Right(notes);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionNoteEntity>> updateSessionNotes({
    required String sessionId,
    required String content,
    required String updatedBy,
  }) async {
    try {
      final notes = await remoteDataSource.updateSessionNotes(
        sessionId: sessionId,
        content: content,
        updatedBy: updatedBy,
      );
      return Right(notes);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<SessionNoteEntity> watchSessionNotes(String sessionId) {
    return remoteDataSource.watchSessionNotes(sessionId);
  }
}
