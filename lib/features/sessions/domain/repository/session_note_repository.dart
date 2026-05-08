import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';

abstract class SessionNoteRepository {
  Future<Either<Failure, SessionNoteEntity>> getSessionNotes(String sessionId);
  Future<Either<Failure, SessionNoteEntity>> updateSessionNotes({
    required String sessionId,
    required String content,
    required String updatedBy,
  });
  Stream<SessionNoteEntity> watchSessionNotes(String sessionId);
}
