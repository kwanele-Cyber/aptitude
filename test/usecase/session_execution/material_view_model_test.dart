import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/session_material.dart';
import 'package:myapp/core/data/repositories/material_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/usecase/session_execution/view_model/material_view_model.dart';

void main() {
  late FakeMaterialRepository materialRepo;
  late MaterialViewModel viewModel;

  setUp(() {
    materialRepo = FakeMaterialRepository();
    viewModel = MaterialViewModel(
      sessionId: 'session_1',
      materialRepo: materialRepo,
      currentUidProvider: () async => 'user_1',
    );
  });

  group('MaterialViewModel share materials use cases', () {
    test('shareMaterial adds a material with url and type', () async {
      await viewModel.shareMaterial(
        name: 'Lesson Notes',
        url: 'https://docs.example.com/notes',
        type: SessionMaterialType.document,
        fileSize: 204800,
      );

      expect(materialRepo.materials, hasLength(1));
      expect(materialRepo.materials.single.name, 'Lesson Notes');
      expect(materialRepo.materials.single.type, SessionMaterialType.document);
      expect(materialRepo.materials.single.fileSize, 204800);
    });

    test('shareMaterial rejects empty name', () async {
      await viewModel.shareMaterial(name: '', url: 'https://example.com/doc');

      expect(materialRepo.materials, isEmpty);
      expect(viewModel.errorMessage, 'Material name is required');
    });

    test('shareMaterial rejects empty url', () async {
      await viewModel.shareMaterial(name: 'Notes', url: '');

      expect(materialRepo.materials, isEmpty);
      expect(viewModel.errorMessage, 'Material URL is required');
    });

    test('shareMaterial rejects invalid url', () async {
      await viewModel.shareMaterial(name: 'Notes', url: 'not-a-url');

      expect(materialRepo.materials, isEmpty);
      expect(viewModel.errorMessage, 'Material URL must be a valid URL');
    });

    test('shareMaterial supports image type', () async {
      await viewModel.shareMaterial(
        name: 'Diagram',
        url: 'https://images.example.com/diagram.png',
        type: SessionMaterialType.image,
      );

      expect(materialRepo.materials.single.type, SessionMaterialType.image);
    });

    test('shareMaterial stores link type material', () async {
      await viewModel.shareMaterial(
        name: 'Reference',
        url: 'https://example.com/resource',
        type: SessionMaterialType.link,
      );

      final material = materialRepo.materials.single;
      expect(material.type, SessionMaterialType.link);
      expect(material.url, 'https://example.com/resource');
    });

    test('loadMaterials populates the materials list', () async {
      materialRepo.materials.addAll([
        _material(id: 'm1', uploadedAt: DateTime(2026, 1, 1)),
        _material(id: 'm2', uploadedAt: DateTime(2026, 6, 1)),
      ]);

      await viewModel.loadMaterials();

      expect(viewModel.materials, hasLength(2));
      expect(viewModel.materials[0].id, 'm2'); // newest first
    });

    test('loadMaterials returns empty list when none exist', () async {
      await viewModel.loadMaterials();

      expect(viewModel.materials, isEmpty);
    });

    test('deleteMaterial removes own material', () async {
      final material = _material(uploadedBy: 'user_1');
      materialRepo.materials.add(material);

      await viewModel.deleteMaterial(material);

      expect(materialRepo.materials, isEmpty);
    });

    test('deleteMaterial rejects deleting another user material', () async {
      final material = _material(uploadedBy: 'user_2');
      materialRepo.materials.add(material);

      await viewModel.deleteMaterial(material);

      expect(materialRepo.materials, hasLength(1));
      expect(viewModel.errorMessage, 'You can only delete materials you uploaded');
    });

    test('isUploading is true during upload', () async {
      expect(viewModel.isUploading, false);

      final future = viewModel.shareMaterial(
        name: 'Notes',
        url: 'https://example.com/notes',
      );

      expect(viewModel.isUploading, true);
      await future;
      expect(viewModel.isUploading, false);
    });

    test('materials sort by most recent first', () async {
      final older = _material(id: 'm1', uploadedAt: DateTime(2026, 1, 1));
      final newer = _material(id: 'm2', uploadedAt: DateTime(2026, 6, 1));
      materialRepo.materials.addAll([newer, older]); // reverse insertion order

      await viewModel.loadMaterials();

      expect(viewModel.materials[0].id, 'm2');
      expect(viewModel.materials[1].id, 'm1');
    });
  });
}

SessionMaterial _material({
  String id = 'material_1',
  String name = 'Test Material',
  String url = 'https://example.com/doc',
  SessionMaterialType type = SessionMaterialType.document,
  String uploadedBy = 'user_1',
  DateTime? uploadedAt,
  int fileSize = 1024,
}) {
  return SessionMaterial(
    id: id,
    sessionId: 'session_1',
    name: name,
    url: url,
    type: type,
    uploadedBy: uploadedBy,
    uploadedAt: uploadedAt ?? DateTime.now(),
    fileSize: fileSize,
  );
}

class FakeMaterialRepository extends MaterialRepository {
  FakeMaterialRepository() : super(databaseService: _NoopDatabaseService());

  final List<SessionMaterial> materials = [];

  @override
  Future<void> uploadMaterial(SessionMaterial material) async {
    materials.add(material);
  }

  @override
  Future<List<SessionMaterial>> getSessionMaterials(String sessionId) async {
    return materials
        .where((m) => m.sessionId == sessionId)
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<void> deleteMaterial(String sessionId, String materialId) async {
    materials.removeWhere(
      (m) => m.sessionId == sessionId && m.id == materialId,
    );
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
