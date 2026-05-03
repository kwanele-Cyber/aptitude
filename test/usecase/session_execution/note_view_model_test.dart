import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/session_note.dart';
import 'package:myapp/core/data/repositories/note_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/usecase/session_execution/view_model/note_view_model.dart';

void main() {
  late FakeNoteRepository noteRepo;
  late NoteViewModel viewModel;

  setUp(() {
    noteRepo = FakeNoteRepository();
    viewModel = NoteViewModel(
      sessionId: 'session_1',
      noteRepo: noteRepo,
      currentUidProvider: () async => 'user_1',
    );
  });

  group('NoteViewModel session notes use cases', () {
    test('addNote creates a note with content and author', () async {
      await viewModel.addNote(content: 'Great session, learned a lot!');

      expect(noteRepo.notes, hasLength(1));
      expect(noteRepo.notes.single.content, 'Great session, learned a lot!');
      expect(noteRepo.notes.single.createdBy, 'user_1');
    });

    test('addNote rejects empty content', () async {
      await viewModel.addNote(content: '   ');

      expect(noteRepo.notes, isEmpty);
      expect(viewModel.errorMessage, 'Note content cannot be empty');
    });

    test('loadNotes populates the notes list', () async {
      noteRepo.notes.addAll([
        _note(id: 'n1'),
        _note(id: 'n2'),
      ]);

      await viewModel.loadNotes();

      expect(viewModel.notes, hasLength(2));
    });

    test('notes sort by most recent first', () async {
      final older = _note(id: 'n1', createdAt: DateTime(2026, 1, 1));
      final newer = _note(id: 'n2', createdAt: DateTime(2026, 6, 1));
      noteRepo.notes.addAll([older, newer]);

      await viewModel.loadNotes();

      expect(viewModel.notes[0].id, 'n2');
      expect(viewModel.notes[1].id, 'n1');
    });

    test('editNote updates content and sets updatedAt', () async {
      final note = _note();
      noteRepo.notes.add(note);

      await viewModel.editNote(note: note, newContent: 'Updated content');

      expect(noteRepo.notes.single.content, 'Updated content');
      expect(noteRepo.notes.single.updatedAt, isNotNull);
    });

    test('editNote rejects editing another users note', () async {
      final note = _note(createdBy: 'user_2');
      noteRepo.notes.add(note);

      await viewModel.editNote(note: note, newContent: 'Hacked');

      expect(noteRepo.notes.single.content, 'Test note');
      expect(viewModel.errorMessage, 'You can only edit your own notes');
    });

    test('deleteNote removes own note', () async {
      final note = _note(createdBy: 'user_1');
      noteRepo.notes.add(note);

      await viewModel.deleteNote(note);

      expect(noteRepo.notes, isEmpty);
    });

    test('deleteNote rejects deleting another users note', () async {
      final note = _note(createdBy: 'user_2');
      noteRepo.notes.add(note);

      await viewModel.deleteNote(note);

      expect(noteRepo.notes, hasLength(1));
      expect(viewModel.errorMessage, 'You can only delete your own notes');
    });

    test('togglePin flips the pinned state', () async {
      final note = _note(isPinned: false);
      noteRepo.notes.add(note);

      await viewModel.togglePin(note);

      expect(noteRepo.notes.single.isPinned, true);
    });

    test('pinnedNotes returns only pinned notes', () async {
      noteRepo.notes.addAll([
        _note(id: 'n1', isPinned: true),
        _note(id: 'n2', isPinned: false),
        _note(id: 'n3', isPinned: true),
      ]);

      await viewModel.loadNotes();

      expect(viewModel.pinnedNotes, hasLength(2));
      expect(viewModel.pinnedNotes.every((n) => n.isPinned), true);
    });
  });
}

SessionNote _note({
  String id = 'note_1',
  String content = 'Test note',
  String createdBy = 'user_1',
  DateTime? createdAt,
  bool isPinned = false,
}) {
  return SessionNote(
    id: id,
    sessionId: 'session_1',
    content: content,
    createdBy: createdBy,
    createdAt: createdAt ?? DateTime.now(),
    isPinned: isPinned,
  );
}

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository() : super(databaseService: _NoopDatabaseService());

  final List<SessionNote> notes = [];

  @override
  Future<void> addNote(SessionNote note) async {
    notes.add(note);
  }

  @override
  Future<List<SessionNote>> getSessionNotes(String sessionId) async {
    return notes
        .where((n) => n.sessionId == sessionId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> updateNote(SessionNote note) async {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      notes.add(note);
    } else {
      notes[index] = note;
    }
  }

  @override
  Future<void> deleteNote(String sessionId, String noteId) async {
    notes.removeWhere((n) => n.sessionId == sessionId && n.id == noteId);
  }
}

class _NoopDatabaseService implements DatabaseService<DataSnapshot> {
  @override
  Future<void> create({
    required String location,
    required Map<String, dynamic> data,
  }) async {}

  @override
  Future<void> delete({required String location}) async {}

  @override
  Future<DataSnapshot?> list({required String location}) async => null;

  @override
  Future<DataSnapshot?> read({required String location}) async => null;

  @override
  Future<void> update({
    required String location,
    required Map<String, dynamic> data,
  }) async {}
}
