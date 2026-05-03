import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session_note.dart';
import 'package:myapp/core/data/repositories/note_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteRepository _noteRepo;
  final AuthService? _auth;
  final Future<String?> Function()? _currentUidProvider;
  final String sessionId;

  NoteViewModel({
    required this.sessionId,
    NoteRepository? noteRepo,
    AuthService? auth,
    Future<String?> Function()? currentUidProvider,
  }) : _noteRepo = noteRepo ?? NoteRepository(),
       _auth = auth,
       _currentUidProvider = currentUidProvider;

  List<SessionNote> _notes = [];
  List<SessionNote> get notes => _notes;

  List<SessionNote> get pinnedNotes =>
      _notes.where((n) => n.isPinned).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _notes = await _noteRepo.getSessionNotes(sessionId);
    } catch (e) {
      _errorMessage = 'Could not load notes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote({required String content}) async {
    _clearError();
    if (content.trim().isEmpty) {
      _setError('Note content cannot be empty');
      return;
    }

    final uid = await _currentUid();
    if (uid == null) {
      _setError('You must be signed in to add notes');
      return;
    }

    final note = SessionNote(
      id: const Uuid().v4(),
      sessionId: sessionId,
      content: content.trim(),
      createdBy: uid,
      createdAt: DateTime.now(),
    );

    await _noteRepo.addNote(note);
    await loadNotes();
  }

  Future<void> editNote({
    required SessionNote note,
    required String newContent,
  }) async {
    _clearError();
    if (newContent.trim().isEmpty) {
      _setError('Note content cannot be empty');
      return;
    }

    final uid = await _currentUid();
    if (uid == null) {
      _setError('You must be signed in to edit notes');
      return;
    }
    if (note.createdBy != uid) {
      _setError('You can only edit your own notes');
      return;
    }

    final updated = note.copyWith(
      content: newContent.trim(),
      updatedAt: DateTime.now(),
    );
    await _noteRepo.updateNote(updated);
    await loadNotes();
  }

  Future<void> deleteNote(SessionNote note) async {
    _clearError();

    final uid = await _currentUid();
    if (uid == null) {
      _setError('You must be signed in to delete notes');
      return;
    }
    if (note.createdBy != uid) {
      _setError('You can only delete your own notes');
      return;
    }

    await _noteRepo.deleteNote(note.sessionId, note.id);
    await loadNotes();
  }

  Future<void> togglePin(SessionNote note) async {
    _clearError();
    final updated = note.copyWith(isPinned: !note.isPinned);
    await _noteRepo.updateNote(updated);
    await loadNotes();
  }

  Future<String?> _currentUid() async {
    if (_currentUidProvider != null) {
      return _currentUidProvider();
    }
    return (await (_auth ?? AuthService()).getCurrentUser())?.uid;
  }
}
