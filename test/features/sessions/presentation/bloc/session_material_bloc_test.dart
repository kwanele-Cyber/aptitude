import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';
import 'package:myapp/features/sessions/domain/usecases/delete_material_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_materials_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/upload_material_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockUploadMaterialUseCase extends Mock implements UploadMaterialUseCase {}
class MockDeleteMaterialUseCase extends Mock implements DeleteMaterialUseCase {}
class MockGetSessionMaterialsUseCase extends Mock
    implements GetSessionMaterialsUseCase {}

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
  late SessionMaterialBloc bloc;
  late MockUploadMaterialUseCase mockUploadUseCase;
  late MockDeleteMaterialUseCase mockDeleteUseCase;
  late MockGetSessionMaterialsUseCase mockGetMaterialsUseCase;

  setUpAll(() {
    registerFallbackValue(UploadMaterialParams(
      sessionId: '',
      file: File(''),
      uploadedBy: '',
    ));
    registerFallbackValue(DeleteMaterialParams(
      materialId: '',
      sessionId: '',
    ));
    registerFallbackValue(GetSessionMaterialsParams(sessionId: ''));
  });

  setUp(() {
    mockUploadUseCase = MockUploadMaterialUseCase();
    mockDeleteUseCase = MockDeleteMaterialUseCase();
    mockGetMaterialsUseCase = MockGetSessionMaterialsUseCase();

    bloc = SessionMaterialBloc(
      uploadMaterialUseCase: mockUploadUseCase,
      deleteMaterialUseCase: mockDeleteUseCase,
      getSessionMaterialsUseCase: mockGetMaterialsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadSessionMaterialsRequested', () {
    blocTest<SessionMaterialBloc, SessionMaterialState>(
      'emits [SessionMaterialLoading, SessionMaterialsLoaded] on success',
      build: () {
        when(() => mockGetMaterialsUseCase(any()))
            .thenAnswer((_) async => Right([tMaterial]));
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadSessionMaterialsRequested(sessionId: 'session1'),
      ),
      expect: () => [
        isA<SessionMaterialLoading>(),
        isA<SessionMaterialsLoaded>().having(
          (s) => s.materials,
          'materials',
          [tMaterial],
        ),
      ],
    );

    blocTest<SessionMaterialBloc, SessionMaterialState>(
      'emits [SessionMaterialLoading, SessionMaterialError] on failure',
      build: () {
        when(() => mockGetMaterialsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadSessionMaterialsRequested(sessionId: 'session1'),
      ),
      expect: () => [
        isA<SessionMaterialLoading>(),
        isA<SessionMaterialError>(),
      ],
    );
  });

  group('UploadMaterialRequested', () {
    final event = UploadMaterialRequested(
      sessionId: 'session1',
      file: File('/tmp/test.pdf'),
      uploadedBy: 'user1',
    );

    blocTest<SessionMaterialBloc, SessionMaterialState>(
      'emits [SessionMaterialUploading, SessionMaterialUploaded, '
          'SessionMaterialsLoaded] on success',
      build: () {
        when(() => mockUploadUseCase(any()))
            .thenAnswer((_) async => Right(tMaterial));
        when(() => mockGetMaterialsUseCase(any()))
            .thenAnswer((_) async => Right([tMaterial]));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionMaterialUploading>(),
        isA<SessionMaterialUploaded>().having(
          (s) => s.material,
          'material',
          tMaterial,
        ),
        isA<SessionMaterialsLoaded>().having(
          (s) => s.materials,
          'materials',
          [tMaterial],
        ),
      ],
    );

    blocTest<SessionMaterialBloc, SessionMaterialState>(
      'emits [SessionMaterialUploading, SessionMaterialError] '
          'when upload fails',
      build: () {
        when(() => mockUploadUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionMaterialUploading>(),
        isA<SessionMaterialError>(),
      ],
    );
  });

  group('DeleteMaterialRequested', () {
    final event = DeleteMaterialRequested(
      materialId: 'material1',
      sessionId: 'session1',
    );

    blocTest<SessionMaterialBloc, SessionMaterialState>(
      'emits [SessionMaterialLoading, SessionMaterialDeleted, '
          'SessionMaterialsLoaded] on success',
      build: () {
        when(() => mockDeleteUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetMaterialsUseCase(any()))
            .thenAnswer((_) async => Right(<SessionMaterialEntity>[]));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionMaterialLoading>(),
        isA<SessionMaterialDeleted>().having(
          (s) => s.materialId,
          'materialId',
          'material1',
        ),
        isA<SessionMaterialsLoaded>().having(
          (s) => s.materials,
          'materials',
          <SessionMaterialEntity>[],
        ),
      ],
    );

    blocTest<SessionMaterialBloc, SessionMaterialState>(
      'emits [SessionMaterialLoading, SessionMaterialError] '
          'when delete fails',
      build: () {
        when(() => mockDeleteUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionMaterialLoading>(),
        isA<SessionMaterialError>(),
      ],
    );
  });
}
