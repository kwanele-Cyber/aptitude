import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';

class UpdateSessionNotesUseCase
    implements UseCase<SessionNoteEntity, UpdateSessionNotesParams> {
  final SessionNoteRepository repository;

  UpdateSessionNotesUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionNoteEntity>> call(
      UpdateSessionNotesParams params) async {
    return repository.updateSessionNotes(
      sessionId: params.sessionId,
      content: params.content,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateSessionNotesParams {
  final String sessionId;
  final String content;
  final String updatedBy;

  UpdateSessionNotesParams({
    required this.sessionId,
    required this.content,
    required this.updatedBy,
  });
}
