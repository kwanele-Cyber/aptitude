import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_material_remote_datasource.dart';
import 'package:myapp/features/sessions/data/models/session_material_model.dart';
import 'package:myapp/features/sessions/data/repository/session_material_repository_impl.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';

class MockSessionMaterialRemoteDataSource extends Mock
    implements SessionMaterialRemoteDataSource {}

final tMaterialModel = SessionMaterialModel(
  id: 'material1',
  sessionId: 'session1',
  fileName: 'notes.pdf',
  fileUrl: 'https://storage.example.com/notes.pdf',
  fileSize: 102400,
  mimeType: 'application/pdf',
  uploadedBy: 'user1',
  uploadedAt: DateTime(2025, 2, 1, 10, 0),
);

void main() {
  late SessionMaterialRepositoryImpl repository;
  late MockSessionMaterialRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockSessionMaterialRemoteDataSource();
    repository = SessionMaterialRepositoryImpl(remoteDataSource: mockRemote);
  });

  setUpAll(() {
    registerFallbackValue(File(''));
  });

  group('uploadMaterial', () {
    test('should upload material on success', () async {
      when(() => mockRemote.uploadMaterial(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
            uploadedBy: any(named: 'uploadedBy'),
          )).thenAnswer((_) async => tMaterialModel);

      final file = File('/tmp/test.pdf');
      final result =
          await repository.uploadMaterial(sessionId: 'session1', file: file, uploadedBy: 'user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tMaterialModel), isA<SessionMaterialEntity>());
      verify(() => mockRemote.uploadMaterial(
            sessionId: 'session1',
            file: file,
            uploadedBy: 'user1',
          )).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.uploadMaterial(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
            uploadedBy: any(named: 'uploadedBy'),
          )).thenThrow(ServerException());

      final result = await repository.uploadMaterial(
          sessionId: 'session1', file: File('/tmp/test.pdf'), uploadedBy: 'user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.uploadMaterial(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
            uploadedBy: any(named: 'uploadedBy'),
          )).thenThrow(Exception());

      final result = await repository.uploadMaterial(
          sessionId: 'session1', file: File('/tmp/test.pdf'), uploadedBy: 'user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('deleteMaterial', () {
    test('should delete material on success', () async {
      when(() => mockRemote.deleteMaterial(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteMaterial('material1', 'session1');

      expect(result.isRight(), true);
      verify(() => mockRemote.deleteMaterial('material1', 'session1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.deleteMaterial(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.deleteMaterial('material1', 'session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.deleteMaterial(any(), any()))
          .thenThrow(Exception());

      final result = await repository.deleteMaterial('material1', 'session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getSessionMaterials', () {
    test('should get materials on success', () async {
      when(() => mockRemote.getSessionMaterials(any()))
          .thenAnswer((_) async => [tMaterialModel]);

      final result = await repository.getSessionMaterials('session1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<SessionMaterialEntity>>());
      verify(() => mockRemote.getSessionMaterials('session1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getSessionMaterials(any()))
          .thenThrow(ServerException());

      final result = await repository.getSessionMaterials('session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.getSessionMaterials(any()))
          .thenThrow(Exception());

      final result = await repository.getSessionMaterials('session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
