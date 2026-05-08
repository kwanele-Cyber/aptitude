import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_note_remote_datasource.dart';
import 'package:myapp/features/sessions/data/models/session_note_model.dart';
import 'package:myapp/features/sessions/data/repository/session_note_repository_impl.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';

class MockSessionNoteRemoteDataSource extends Mock
    implements SessionNoteRemoteDataSource {}

final tNoteModel = SessionNoteModel(
  sessionId: 'session1',
  content: 'Session notes content.',
  updatedBy: 'user1',
  updatedAt: DateTime(2025, 2, 1, 10, 0),
);

void main() {
  late SessionNoteRepositoryImpl repository;
  late MockSessionNoteRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockSessionNoteRemoteDataSource();
    repository = SessionNoteRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('getSessionNotes', () {
    test('should get notes on success', () async {
      when(() => mockRemote.getSessionNotes(any()))
          .thenAnswer((_) async => tNoteModel);

      final result = await repository.getSessionNotes('session1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tNoteModel), isA<SessionNoteEntity>());
      verify(() => mockRemote.getSessionNotes('session1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getSessionNotes(any()))
          .thenThrow(ServerException());

      final result = await repository.getSessionNotes('session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.getSessionNotes(any())).thenThrow(Exception());

      final result = await repository.getSessionNotes('session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateSessionNotes', () {
    test('should update notes on success', () async {
      when(() => mockRemote.updateSessionNotes(
            sessionId: any(named: 'sessionId'),
            content: any(named: 'content'),
            updatedBy: any(named: 'updatedBy'),
          )).thenAnswer((_) async => tNoteModel);

      final result = await repository.updateSessionNotes(
        sessionId: 'session1',
        content: 'Updated notes.',
        updatedBy: 'user1',
      );

      expect(result.isRight(), true);
      verify(() => mockRemote.updateSessionNotes(
            sessionId: 'session1',
            content: 'Updated notes.',
            updatedBy: 'user1',
          )).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.updateSessionNotes(
            sessionId: any(named: 'sessionId'),
            content: any(named: 'content'),
            updatedBy: any(named: 'updatedBy'),
          )).thenThrow(ServerException());

      final result = await repository.updateSessionNotes(
        sessionId: 'session1',
        content: 'Updated notes.',
        updatedBy: 'user1',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateSessionNotes(
            sessionId: any(named: 'sessionId'),
            content: any(named: 'content'),
            updatedBy: any(named: 'updatedBy'),
          )).thenThrow(Exception());

      final result = await repository.updateSessionNotes(
        sessionId: 'session1',
        content: 'Updated notes.',
        updatedBy: 'user1',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('watchSessionNotes', () {
    test('should return stream from remote datasource', () {
      final streamController = StreamController<SessionNoteModel>();
      when(() => mockRemote.watchSessionNotes(any()))
          .thenAnswer((_) => streamController.stream);

      final stream = repository.watchSessionNotes('session1');

      expect(stream, isA<Stream<SessionNoteEntity>>());
      verify(() => mockRemote.watchSessionNotes('session1')).called(1);

      streamController.close();
    });
  });
}
