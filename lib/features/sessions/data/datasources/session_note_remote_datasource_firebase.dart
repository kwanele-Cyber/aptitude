import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/sessions/data/datasources/session_note_remote_datasource.dart';
import 'package:myapp/features/sessions/data/models/session_note_model.dart';

class SessionNoteRemoteDataSourceFirebase
    implements SessionNoteRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  SessionNoteRemoteDataSourceFirebase({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  DatabaseReference _notesRef(String sessionId) =>
      _database.ref('sessionNotes').child(sessionId);

  @override
  Future<SessionNoteModel> getSessionNotes(String sessionId) async {
    try {
      final snapshot = await _notesRef(sessionId).get();
      if (!snapshot.exists) {
        return SessionNoteModel(
          sessionId: sessionId,
          content: '',
          updatedBy: '',
          updatedAt: DateTime.now(),
        );
      }

      return SessionNoteModel.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException();
    }
  }

  @override
  Future<SessionNoteModel> updateSessionNotes({
    required String sessionId,
    required String content,
    required String updatedBy,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw const ServerException('Not authenticated');

      final noteData = {
        'sessionId': sessionId,
        'content': content,
        'updatedBy': updatedBy,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _notesRef(sessionId).set(noteData);
      return SessionNoteModel(
        sessionId: sessionId,
        content: content,
        updatedBy: updatedBy,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException();
    }
  }

  @override
  Stream<SessionNoteModel> watchSessionNotes(String sessionId) {
    return _notesRef(sessionId).onValue.map((event) {
      if (!event.snapshot.exists) {
        return SessionNoteModel(
          sessionId: sessionId,
          content: '',
          updatedBy: '',
          updatedAt: DateTime.now(),
        );
      }
      return SessionNoteModel.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }
}
