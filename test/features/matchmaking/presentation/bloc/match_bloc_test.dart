import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/usecases/create_direct_match_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/fetch_match_history_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/generate_matches_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/save_match_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/submit_match_feedback_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/update_match_status_usecase.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_bloc.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_event.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_state.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:bloc_test/bloc_test.dart';

class MockGenerateMatchesUseCase extends Mock
    implements GenerateMatchesUseCase {}

class MockUpdateMatchStatusUseCase extends Mock
    implements UpdateMatchStatusUseCase {}

class MockSaveMatchUseCase extends Mock implements SaveMatchUseCase {}

class MockFetchMatchHistoryUseCase extends Mock
    implements FetchMatchHistoryUseCase {}

class MockSubmitMatchFeedbackUseCase extends Mock
    implements SubmitMatchFeedbackUseCase {}

class MockCreateDirectMatchUseCase extends Mock
    implements CreateDirectMatchUseCase {}

final tMatch = MatchEntity(
  id: 'match1',
  targetUserId: 'user2',
  targetSkillId: 'skill2',
  matchedSkillId: 'skill1',
  score: 85,
  createdAt: DateTime(2025, 1, 1),
  targetUserName: 'User 2',
  targetSkillTitle: 'Flutter',
  targetSkillCategory: 'Tech',
  targetSkillLevel: SkillLevel.intermediate,
  targetSkillFormat: SkillFormat.online,
);

void main() {
  late MatchBloc bloc;
  late MockGenerateMatchesUseCase mockGenerateUseCase;
  late MockUpdateMatchStatusUseCase mockUpdateStatusUseCase;
  late MockSaveMatchUseCase mockSaveUseCase;
  late MockFetchMatchHistoryUseCase mockFetchHistoryUseCase;
  late MockSubmitMatchFeedbackUseCase mockSubmitFeedbackUseCase;
  late MockCreateDirectMatchUseCase mockCreateDirectUseCase;

  setUpAll(() {
    registerFallbackValue(const GenerateMatchesParams(userId: ''));
    registerFallbackValue(const UpdateMatchStatusParams(
      matchId: '',
      status: MatchStatus.pending,
    ));
    registerFallbackValue(const SaveMatchParams(matchId: ''));
    registerFallbackValue(const FetchMatchHistoryParams(userId: ''));
    registerFallbackValue(const SubmitMatchFeedbackParams(
      matchId: '',
      rating: 1,
    ));
    registerFallbackValue(const CreateDirectMatchParams(matchData: {}));
  });

  setUp(() {
    mockGenerateUseCase = MockGenerateMatchesUseCase();
    mockUpdateStatusUseCase = MockUpdateMatchStatusUseCase();
    mockSaveUseCase = MockSaveMatchUseCase();
    mockFetchHistoryUseCase = MockFetchMatchHistoryUseCase();
    mockSubmitFeedbackUseCase = MockSubmitMatchFeedbackUseCase();
    mockCreateDirectUseCase = MockCreateDirectMatchUseCase();

    bloc = MatchBloc(
      generateMatchesUseCase: mockGenerateUseCase,
      updateMatchStatusUseCase: mockUpdateStatusUseCase,
      saveMatchUseCase: mockSaveUseCase,
      fetchMatchHistoryUseCase: mockFetchHistoryUseCase,
      submitMatchFeedbackUseCase: mockSubmitFeedbackUseCase,
      createDirectMatchUseCase: mockCreateDirectUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FetchMatchesRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchesLoaded] on success',
      build: () {
        when(() => mockGenerateUseCase(any()))
            .thenAnswer((_) async => Right([tMatch]));
        when(() => mockFetchHistoryUseCase(any()))
            .thenAnswer((_) async => Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchMatchesRequested(userId: 'user1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchesLoaded>().having(
          (s) => s.matches,
          'matches',
          [tMatch],
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockGenerateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchMatchesRequested(userId: 'user1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });

  group('AcceptMatchRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchStatusUpdated] on success',
      build: () {
        when(() => mockUpdateStatusUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(AcceptMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchStatusUpdated>().having(
          (s) => s.status,
          'status',
          MatchStatus.accepted,
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockUpdateStatusUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(AcceptMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });

  group('RejectMatchRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchStatusUpdated] on success',
      build: () {
        when(() => mockUpdateStatusUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(RejectMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchStatusUpdated>().having(
          (s) => s.status,
          'status',
          MatchStatus.rejected,
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockUpdateStatusUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(RejectMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });

  group('IgnoreMatchRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchStatusUpdated] on success',
      build: () {
        when(() => mockUpdateStatusUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(IgnoreMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchStatusUpdated>().having(
          (s) => s.status,
          'status',
          MatchStatus.ignored,
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockUpdateStatusUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(IgnoreMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });

  group('SaveMatchRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchStatusUpdated] on success',
      build: () {
        when(() => mockSaveUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchStatusUpdated>().having(
          (s) => s.status,
          'status',
          MatchStatus.pending,
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockSaveUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveMatchRequested(matchId: 'match1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });

  group('FetchMatchHistoryRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchHistoryLoaded] on success',
      build: () {
        when(() => mockFetchHistoryUseCase(any()))
            .thenAnswer((_) async => Right([tMatch]));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchMatchHistoryRequested(userId: 'user1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchHistoryLoaded>().having(
          (s) => s.matches,
          'matches',
          [tMatch],
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockFetchHistoryUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchMatchHistoryRequested(userId: 'user1')),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });

  group('SubmitFeedbackRequested', () {
    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, FeedbackSubmitted] on success',
      build: () {
        when(() => mockSubmitFeedbackUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(SubmitFeedbackRequested(matchId: 'match1', rating: 4)),
      expect: () => [
        isA<MatchLoading>(),
        isA<FeedbackSubmitted>().having(
          (s) => s.matchId,
          'matchId',
          'match1',
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchError] on failure',
      build: () {
        when(() => mockSubmitFeedbackUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(SubmitFeedbackRequested(matchId: 'match1', rating: 4)),
      expect: () => [
        isA<MatchLoading>(),
        isA<MatchError>(),
      ],
    );
  });
}
