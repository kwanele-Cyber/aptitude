import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/sessions/data/models/session_material_model.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';

void main() {
  group('SessionMaterialModel', () {
    final tJson = {
      'sessionId': 'session1',
      'fileName': 'notes.pdf',
      'fileUrl': 'https://storage.example.com/notes.pdf',
      'fileSize': 102400,
      'mimeType': 'application/pdf',
      'uploadedBy': 'user1',
      'uploadedAt': '2025-02-01T10:00:00.000',
    };

    test('fromJson should return a valid model', () {
      final model = SessionMaterialModel.fromJson('material1', tJson);

      expect(model.id, 'material1');
      expect(model.sessionId, 'session1');
      expect(model.fileName, 'notes.pdf');
      expect(model.fileUrl, 'https://storage.example.com/notes.pdf');
      expect(model.fileSize, 102400);
      expect(model.mimeType, 'application/pdf');
      expect(model.uploadedBy, 'user1');
    });

    test('toJson should return a valid JSON map', () {
      final model = SessionMaterialModel(
        id: 'material1',
        sessionId: 'session1',
        fileName: 'notes.pdf',
        fileUrl: 'https://storage.example.com/notes.pdf',
        fileSize: 102400,
        mimeType: 'application/pdf',
        uploadedBy: 'user1',
        uploadedAt: DateTime(2025, 2, 1, 10, 0),
      );

      final json = model.toJson();

      expect(json['sessionId'], 'session1');
      expect(json['fileName'], 'notes.pdf');
      expect(json['fileUrl'], 'https://storage.example.com/notes.pdf');
      expect(json['fileSize'], 102400);
      expect(json['mimeType'], 'application/pdf');
      expect(json['uploadedBy'], 'user1');
    });

    test('should extend SessionMaterialEntity', () {
      final model = SessionMaterialModel(
        id: 'material1',
        sessionId: 'session1',
        fileName: 'notes.pdf',
        fileUrl: 'https://storage.example.com/notes.pdf',
        fileSize: 102400,
        mimeType: 'application/pdf',
        uploadedBy: 'user1',
        uploadedAt: DateTime(2025, 2, 1, 10, 0),
      );

      expect(model, isA<SessionMaterialEntity>());
    });

    test('fromJson should handle null fields gracefully', () {
      final minimalJson = {
        'sessionId': 'session1',
        'fileName': 'notes.pdf',
        'fileUrl': 'https://storage.example.com/notes.pdf',
      };

      final model = SessionMaterialModel.fromJson('material1', minimalJson);

      expect(model.fileSize, 0);
      expect(model.mimeType, 'application/octet-stream');
      expect(model.uploadedBy, '');
    });
  });
}
