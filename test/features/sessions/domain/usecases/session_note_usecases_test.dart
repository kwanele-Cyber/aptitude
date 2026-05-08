import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_notes_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_notes_usecase.dart';

class MockSessionNoteRepository extends Mock
    implements SessionNoteRepository {}

final tNote = SessionNoteEntity(
  sessionId: 'session1',
  content: 'Session notes content.',
  updatedBy: 'user1',
  updatedAt: DateTime(2025, 2, 1, 10, 0),
);

void main() {
  late MockSessionNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionNoteRepository();
  });

  group('GetSessionNotesUseCase', () {
    late GetSessionNotesUseCase useCase;

    setUp(() {
      useCase = GetSessionNotesUseCase(repository: mockRepository);
    });

    test('should get notes on success', () async {
      when(() => mockRepository.getSessionNotes(any()))
          .thenAnswer((_) async => Right(tNote));

      final result = await useCase(
        GetSessionNotesParams(sessionId: 'session1'),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.getSessionNotes('session1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getSessionNotes(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        GetSessionNotesParams(sessionId: 'session1'),
      );

      expect(result.isLeft(), true);
    });
  });

  group('UpdateSessionNotesUseCase', () {
    late UpdateSessionNotesUseCase useCase;

    setUp(() {
      useCase = UpdateSessionNotesUseCase(repository: mockRepository);
    });

    test('should update notes on success', () async {
      when(() => mockRepository.updateSessionNotes(
            sessionId: any(named: 'sessionId'),
            content: any(named: 'content'),
            updatedBy: any(named: 'updatedBy'),
          )).thenAnswer((_) async => Right(tNote));

      final result = await useCase(
        UpdateSessionNotesParams(
          sessionId: 'session1',
          content: 'Updated notes.',
          updatedBy: 'user1',
        ),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.updateSessionNotes(
            sessionId: 'session1',
            content: 'Updated notes.',
            updatedBy: 'user1',
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updateSessionNotes(
            sessionId: any(named: 'sessionId'),
            content: any(named: 'content'),
            updatedBy: any(named: 'updatedBy'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        UpdateSessionNotesParams(
          sessionId: 'session1',
          content: 'Updated notes.',
          updatedBy: 'user1',
        ),
      );

      expect(result.isLeft(), true);
    });
  });
}
