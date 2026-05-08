import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';

class GetSessionNotesUseCase
    implements UseCase<SessionNoteEntity, GetSessionNotesParams> {
  final SessionNoteRepository repository;

  GetSessionNotesUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionNoteEntity>> call(
      GetSessionNotesParams params) async {
    return repository.getSessionNotes(params.sessionId);
  }
}

class GetSessionNotesParams {
  final String sessionId;

  GetSessionNotesParams({required this.sessionId});
}
