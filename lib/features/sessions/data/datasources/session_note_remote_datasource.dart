import 'package:myapp/features/sessions/data/models/session_note_model.dart';

abstract class SessionNoteRemoteDataSource {
  Future<SessionNoteModel> getSessionNotes(String sessionId);
  Future<SessionNoteModel> updateSessionNotes({
    required String sessionId,
    required String content,
    required String updatedBy,
  });
  Stream<SessionNoteModel> watchSessionNotes(String sessionId);
}
