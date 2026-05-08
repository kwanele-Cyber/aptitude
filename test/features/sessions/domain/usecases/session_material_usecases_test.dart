import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_material_repository.dart';
import 'package:myapp/features/sessions/domain/usecases/delete_material_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_materials_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/upload_material_usecase.dart';

class MockSessionMaterialRepository extends Mock
    implements SessionMaterialRepository {}

final tMaterial = SessionMaterialEntity(
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
  late MockSessionMaterialRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionMaterialRepository();
  });

  setUpAll(() {
    registerFallbackValue(File(''));
  });

  group('UploadMaterialUseCase', () {
    late UploadMaterialUseCase useCase;

    setUp(() {
      useCase = UploadMaterialUseCase(repository: mockRepository);
    });

    test('should upload material on success', () async {
      final file = File('/tmp/test.pdf');
      when(() => mockRepository.uploadMaterial(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
            uploadedBy: any(named: 'uploadedBy'),
          )).thenAnswer((_) async => Right(tMaterial));

      final result = await useCase(
        UploadMaterialParams(
          sessionId: 'session1',
          file: file,
          uploadedBy: 'user1',
        ),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.uploadMaterial(
            sessionId: 'session1',
            file: file,
            uploadedBy: 'user1',
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.uploadMaterial(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
            uploadedBy: any(named: 'uploadedBy'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        UploadMaterialParams(
          sessionId: 'session1',
          file: File('/tmp/test.pdf'),
          uploadedBy: 'user1',
        ),
      );

      expect(result.isLeft(), true);
    });
  });

  group('DeleteMaterialUseCase', () {
    late DeleteMaterialUseCase useCase;

    setUp(() {
      useCase = DeleteMaterialUseCase(repository: mockRepository);
    });

    test('should delete material on success', () async {
      when(() => mockRepository.deleteMaterial(any(), any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(
        DeleteMaterialParams(materialId: 'material1', sessionId: 'session1'),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.deleteMaterial('material1', 'session1'))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.deleteMaterial(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        DeleteMaterialParams(materialId: 'material1', sessionId: 'session1'),
      );

      expect(result.isLeft(), true);
    });
  });

  group('GetSessionMaterialsUseCase', () {
    late GetSessionMaterialsUseCase useCase;

    setUp(() {
      useCase = GetSessionMaterialsUseCase(repository: mockRepository);
    });

    test('should get materials on success', () async {
      when(() => mockRepository.getSessionMaterials(any()))
          .thenAnswer((_) async => Right([tMaterial]));

      final result = await useCase(
        GetSessionMaterialsParams(sessionId: 'session1'),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.getSessionMaterials('session1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getSessionMaterials(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        GetSessionMaterialsParams(sessionId: 'session1'),
      );

      expect(result.isLeft(), true);
    });
  });
}
