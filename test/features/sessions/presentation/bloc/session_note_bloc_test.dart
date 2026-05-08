import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_notes_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_notes_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockGetSessionNotesUseCase extends Mock
    implements GetSessionNotesUseCase {}
class MockUpdateSessionNotesUseCase extends Mock
    implements UpdateSessionNotesUseCase {}
class MockSessionNoteRepository extends Mock
    implements SessionNoteRepository {}

final tNote = SessionNoteEntity(
  sessionId: 'session1',
  content: 'Session notes content.',
  updatedBy: 'user1',
  updatedAt: DateTime(2025, 2, 1, 10, 0),
);

void main() {
  late SessionNoteBloc bloc;
  late MockGetSessionNotesUseCase mockGetNotesUseCase;
  late MockUpdateSessionNotesUseCase mockUpdateNotesUseCase;
  late MockSessionNoteRepository mockNoteRepository;

  setUpAll(() {
    registerFallbackValue(GetSessionNotesParams(sessionId: ''));
    registerFallbackValue(UpdateSessionNotesParams(
      sessionId: '',
      content: '',
      updatedBy: '',
    ));
  });

  setUp(() {
    mockGetNotesUseCase = MockGetSessionNotesUseCase();
    mockUpdateNotesUseCase = MockUpdateSessionNotesUseCase();
    mockNoteRepository = MockSessionNoteRepository();

    bloc = SessionNoteBloc(
      getSessionNotesUseCase: mockGetNotesUseCase,
      updateSessionNotesUseCase: mockUpdateNotesUseCase,
      sessionNoteRepository: mockNoteRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadSessionNotesRequested', () {
    blocTest<SessionNoteBloc, SessionNoteState>(
      'emits [SessionNoteLoading, SessionNotesLoaded] on success',
      build: () {
        when(() => mockGetNotesUseCase(any()))
            .thenAnswer((_) async => Right(tNote));
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadSessionNotesRequested(sessionId: 'session1'),
      ),
      expect: () => [
        isA<SessionNoteLoading>(),
        isA<SessionNotesLoaded>().having(
          (s) => s.notes,
          'notes',
          tNote,
        ),
      ],
    );

    blocTest<SessionNoteBloc, SessionNoteState>(
      'emits [SessionNoteLoading, SessionNoteError] on failure',
      build: () {
        when(() => mockGetNotesUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadSessionNotesRequested(sessionId: 'session1'),
      ),
      expect: () => [
        isA<SessionNoteLoading>(),
        isA<SessionNoteError>(),
      ],
    );
  });

  group('UpdateSessionNotesRequested', () {
    blocTest<SessionNoteBloc, SessionNoteState>(
      'emits [SessionNotesUpdated] on success',
      build: () {
        when(() => mockUpdateNotesUseCase(any()))
            .thenAnswer((_) async => Right(tNote));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateSessionNotesRequested(
          sessionId: 'session1',
          content: 'Updated notes.',
          updatedBy: 'user1',
        ),
      ),
      expect: () => [
        isA<SessionNotesUpdated>().having(
          (s) => s.notes,
          'notes',
          tNote,
        ),
      ],
    );

    blocTest<SessionNoteBloc, SessionNoteState>(
      'emits [SessionNoteError] on failure',
      build: () {
        when(() => mockUpdateNotesUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateSessionNotesRequested(
          sessionId: 'session1',
          content: 'Updated notes.',
          updatedBy: 'user1',
        ),
      ),
      expect: () => [
        isA<SessionNoteError>(),
      ],
    );
  });

  group('NotesSubscriptionRequested', () {
    blocTest<SessionNoteBloc, SessionNoteState>(
      'subscribes to realtime notes stream and emits updates',
      build: () {
        final controller = StreamController<SessionNoteEntity>();
        when(() => mockNoteRepository.watchSessionNotes(any()))
            .thenAnswer((_) => controller.stream);

        return bloc;
      },
      act: (bloc) {
        bloc.add(NotesSubscriptionRequested(sessionId: 'session1'));
        bloc.add(NotesRealtimeUpdateReceived(
          sessionId: 'session1',
          content: 'Realtime notes update.',
          updatedBy: 'user2',
          updatedAt: DateTime(2025, 2, 1, 11, 0),
        ));
      },
      expect: () => [
        isA<SessionNotesLoaded>().having(
          (s) => s.notes.content,
          'content',
          'Realtime notes update.',
        ),
      ],
      verify: (_) {
        verify(() => mockNoteRepository.watchSessionNotes('session1'))
            .called(1);
      },
    );
  });

  group('NotesSubscriptionCancelled', () {
    blocTest<SessionNoteBloc, SessionNoteState>(
      'cancels the subscription',
      build: () {
        when(() => mockNoteRepository.watchSessionNotes(any()))
            .thenAnswer((_) => const Stream.empty());
        return bloc;
      },
      act: (bloc) {
        bloc.add(NotesSubscriptionRequested(sessionId: 'session1'));
        bloc.add(NotesSubscriptionCancelled());
      },
      expect: () => [],
    );
  });
}
