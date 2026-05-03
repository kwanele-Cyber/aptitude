import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/session_note.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class NoteRepository {
  final String _path = "session_notes";
  late final DatabaseService<DataSnapshot> _databaseService;

  NoteRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> addNote(SessionNote note) async {
    await _databaseService.create(
      location: "$_path/${note.sessionId}/${note.id}",
      data: note.toJson(),
    );
  }

  Future<List<SessionNote>> getSessionNotes(String sessionId) async {
    final snapshot = await _databaseService.list(location: "$_path/$sessionId");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((v) => SessionNote.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return [];
  }

  Future<void> updateNote(SessionNote note) async {
    await _databaseService.update(
      location: "$_path/${note.sessionId}/${note.id}",
      data: note.toJson(),
    );
  }

  Future<void> deleteNote(String sessionId, String noteId) async {
    await _databaseService.delete(location: "$_path/$sessionId/$noteId");
  }
}
