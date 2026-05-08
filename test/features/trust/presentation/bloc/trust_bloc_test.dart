import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/usecases/appeal_trust_score_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/calculate_trust_score_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/filter_by_trust_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/get_trust_profile_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/update_reputation_usecase.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_bloc.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_event.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCalculateTrustScoreUseCase extends Mock
    implements CalculateTrustScoreUseCase {}

class MockUpdateReputationUseCase extends Mock
    implements UpdateReputationUseCase {}

class MockFilterByTrustUseCase extends Mock
    implements FilterByTrustUseCase {}

class MockGetTrustProfileUseCase extends Mock
    implements GetTrustProfileUseCase {}

class MockAppealTrustScoreUseCase extends Mock
    implements AppealTrustScoreUseCase {}

class MockGetAppealsUseCase extends Mock implements GetAppealsUseCase {}

final tTrustEntity = TrustEntity(
  id: 'trust_user1',
  userId: 'user1',
  score: 75,
  factors: [],
  lastCalculated: DateTime(2025, 1, 1),
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

void main() {
  late TrustBloc bloc;
  late MockCalculateTrustScoreUseCase mockCalculateUseCase;
  late MockUpdateReputationUseCase mockUpdateReputationUseCase;
  late MockFilterByTrustUseCase mockFilterUseCase;
  late MockGetTrustProfileUseCase mockGetProfileUseCase;
  late MockAppealTrustScoreUseCase mockAppealUseCase;
  late MockGetAppealsUseCase mockGetAppealsUseCase;

  setUpAll(() {
    registerFallbackValue(const CalculateTrustScoreParams(userId: ''));
    registerFallbackValue(const UpdateReputationParams(
      userId: '',
      event: '',
      data: {},
    ));
    registerFallbackValue(const FilterByTrustParams(threshold: 0));
    registerFallbackValue(const GetTrustProfileParams(userId: ''));
    registerFallbackValue(
        const AppealTrustScoreParams(userId: '', reason: ''));
    registerFallbackValue(const GetAppealsParams(userId: ''));
  });

  setUp(() {
    mockCalculateUseCase = MockCalculateTrustScoreUseCase();
    mockUpdateReputationUseCase = MockUpdateReputationUseCase();
    mockFilterUseCase = MockFilterByTrustUseCase();
    mockGetProfileUseCase = MockGetTrustProfileUseCase();
    mockAppealUseCase = MockAppealTrustScoreUseCase();
    mockGetAppealsUseCase = MockGetAppealsUseCase();

    bloc = TrustBloc(
      calculateTrustScoreUseCase: mockCalculateUseCase,
      updateReputationUseCase: mockUpdateReputationUseCase,
      filterByTrustUseCase: mockFilterUseCase,
      getTrustProfileUseCase: mockGetProfileUseCase,
      appealTrustScoreUseCase: mockAppealUseCase,
      getAppealsUseCase: mockGetAppealsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CalculateTrustScoreRequested', () {
    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustScoreLoaded] on success',
      build: () {
        when(() => mockCalculateUseCase(any()))
            .thenAnswer((_) async => Right(tTrustEntity));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(CalculateTrustScoreRequested(userId: 'user1')),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustScoreLoaded>().having(
          (s) => s.trust,
          'trust',
          tTrustEntity,
        ),
      ],
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustError] on failure',
      build: () {
        when(() => mockCalculateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(CalculateTrustScoreRequested(userId: 'user1')),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustError>(),
      ],
    );
  });

  group('UpdateReputationRequested', () {
    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustScoreLoaded] on success',
      build: () {
        when(() => mockUpdateReputationUseCase(any()))
            .thenAnswer((_) async => Right(tTrustEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateReputationRequested(
        userId: 'user1',
        event: 'session_completed',
        data: {'sessionId': 'session1'},
      )),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustScoreLoaded>().having(
          (s) => s.trust,
          'trust',
          tTrustEntity,
        ),
      ],
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustError] on failure',
      build: () {
        when(() => mockUpdateReputationUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateReputationRequested(
        userId: 'user1',
        event: 'session_completed',
        data: {},
      )),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustError>(),
      ],
    );
  });

  group('FilterByTrustRequested', () {
    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustFilteredUsersLoaded] on success',
      build: () {
        when(() => mockFilterUseCase(any()))
            .thenAnswer((_) async => const Right(['user1', 'user2']));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FilterByTrustRequested(threshold: 70)),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustFilteredUsersLoaded>().having(
          (s) => s.userIds,
          'userIds',
          ['user1', 'user2'],
        ),
      ],
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustError] on failure',
      build: () {
        when(() => mockFilterUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FilterByTrustRequested(threshold: 70)),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustError>(),
      ],
    );
  });

  group('GetTrustProfileRequested', () {
    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustProfileLoaded] on success',
      build: () {
        when(() => mockGetProfileUseCase(any()))
            .thenAnswer((_) async => Right(tTrustEntity));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(GetTrustProfileRequested(userId: 'user1')),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustProfileLoaded>().having(
          (s) => s.profile,
          'profile',
          tTrustEntity,
        ),
      ],
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustError] on failure',
      build: () {
        when(() => mockGetProfileUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(GetTrustProfileRequested(userId: 'user1')),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustError>(),
      ],
    );
  });

  group('SubmitAppealRequested', () {
    final tAppealEntity = TrustAppealEntity(
      id: 'appeal1',
      userId: 'user1',
      reason: 'Unfair score drop',
      status: AppealStatus.pending,
      createdAt: DateTime(2025, 1, 1),
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, AppealSubmitted] on success',
      build: () {
        when(() => mockAppealUseCase(any()))
            .thenAnswer((_) async => Right(tAppealEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(SubmitAppealRequested(
        userId: 'user1',
        reason: 'Unfair score drop',
      )),
      expect: () => [
        isA<TrustLoading>(),
        isA<AppealSubmitted>().having(
          (s) => s.appeal,
          'appeal',
          tAppealEntity,
        ),
      ],
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustError] on failure',
      build: () {
        when(() => mockAppealUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(SubmitAppealRequested(
        userId: 'user1',
        reason: 'Unfair score drop',
      )),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustError>(),
      ],
    );
  });

  group('GetAppealsRequested', () {
    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, AppealsLoaded] on success',
      build: () {
        when(() => mockGetAppealsUseCase(any()))
            .thenAnswer((_) async => const Right(<TrustAppealEntity>[]));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(GetAppealsRequested(userId: 'user1')),
      expect: () => [
        isA<TrustLoading>(),
        isA<AppealsLoaded>(),
      ],
    );

    blocTest<TrustBloc, TrustState>(
      'emits [TrustLoading, TrustError] on failure',
      build: () {
        when(() => mockGetAppealsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(GetAppealsRequested(userId: 'user1')),
      expect: () => [
        isA<TrustLoading>(),
        isA<TrustError>(),
      ],
    );
  });
}
