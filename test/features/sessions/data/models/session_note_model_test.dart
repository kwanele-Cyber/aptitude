import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/sessions/data/models/session_note_model.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';

void main() {
  group('SessionNoteModel', () {
    final tJson = {
      'sessionId': 'session1',
      'content': 'Covered Flutter widgets and state management.',
      'updatedBy': 'user1',
      'updatedAt': '2025-02-01T10:00:00.000',
    };

    test('fromJson should return a valid model', () {
      final model = SessionNoteModel.fromJson(tJson);

      expect(model.sessionId, 'session1');
      expect(model.content, 'Covered Flutter widgets and state management.');
      expect(model.updatedBy, 'user1');
    });

    test('toJson should return a valid JSON map', () {
      final model = SessionNoteModel(
        sessionId: 'session1',
        content: 'Covered Flutter widgets and state management.',
        updatedBy: 'user1',
        updatedAt: DateTime(2025, 2, 1, 10, 0),
      );

      final json = model.toJson();

      expect(json['sessionId'], 'session1');
      expect(json['content'], 'Covered Flutter widgets and state management.');
      expect(json['updatedBy'], 'user1');
    });

    test('should extend SessionNoteEntity', () {
      final model = SessionNoteModel(
        sessionId: 'session1',
        content: 'Notes content',
        updatedBy: 'user1',
        updatedAt: DateTime(2025, 2, 1, 10, 0),
      );

      expect(model, isA<SessionNoteEntity>());
    });

    test('fromJson should handle null fields gracefully', () {
      final minimalJson = <String, dynamic>{};

      final model = SessionNoteModel.fromJson(minimalJson);

      expect(model.sessionId, '');
      expect(model.content, '');
      expect(model.updatedBy, '');
    });
  });
}
