import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:myapp/features/disputes/domain/usecases/appeal_decision_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/create_dispute_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/report_user_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/resolve_dispute_usecase.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_bloc.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_event.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockReportUserUseCase extends Mock implements ReportUserUseCase {}

class MockCreateDisputeUseCase extends Mock implements CreateDisputeUseCase {}

class MockResolveDisputeUseCase extends Mock implements ResolveDisputeUseCase {}

class MockAppealDecisionUseCase extends Mock implements AppealDecisionUseCase {}

class MockDisputeRepository extends Mock implements DisputeRepository {}

final tDispute = DisputeEntity(
  id: 'dispute1',
  type: DisputeType.report,
  reporterId: 'user1',
  reporterName: 'Alice',
  reportedUserId: 'user2',
  reportedUserName: 'Bob',
  reason: 'Harassment',
  description: 'Inappropriate messages',
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 15, 10, 0),
);

final tDisputes = [tDispute];

void main() {
  late DisputeBloc bloc;
  late MockReportUserUseCase mockReportUser;
  late MockCreateDisputeUseCase mockCreateDispute;
  late MockResolveDisputeUseCase mockResolveDispute;
  late MockAppealDecisionUseCase mockAppealDecision;
  late MockDisputeRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const ReportUserParams(
      reporterId: '',
      reporterName: '',
      reportedUserId: '',
      reportedUserName: '',
      reason: '',
      description: '',
    ));
    registerFallbackValue(const CreateDisputeParams(
      reporterId: '',
      reporterName: '',
      respondentId: '',
      reason: '',
      description: '',
    ));
    registerFallbackValue(const ResolveDisputeParams(
      disputeId: '',
      resolution: '',
      resolvedBy: '',
      status: DisputeStatus.resolved,
    ));
    registerFallbackValue(const AppealDecisionParams(
      disputeId: '',
      appealReason: '',
    ));
  });

  setUp(() {
    mockReportUser = MockReportUserUseCase();
    mockCreateDispute = MockCreateDisputeUseCase();
    mockResolveDispute = MockResolveDisputeUseCase();
    mockAppealDecision = MockAppealDecisionUseCase();
    mockRepository = MockDisputeRepository();
    bloc = DisputeBloc(
      reportUserUseCase: mockReportUser,
      createDisputeUseCase: mockCreateDispute,
      resolveDisputeUseCase: mockResolveDispute,
      appealDecisionUseCase: mockAppealDecision,
      disputeRepository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ReportUserRequested', () {
    final event = ReportUserRequested(
      reporterId: 'user1',
      reporterName: 'Alice',
      reportedUserId: 'user2',
      reportedUserName: 'Bob',
      reason: 'Harassment',
      description: 'Inappropriate messages',
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeReported] on success',
      build: () {
        when(() => mockReportUser(any()))
            .thenAnswer((_) async => Right(tDispute));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        isA<DisputeReported>(),
      ],
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeError] on failure',
      build: () {
        when(() => mockReportUser(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        DisputeError(message: 'Failed to submit report'),
      ],
    );
  });

  group('CreateDisputeRequested', () {
    final event = CreateDisputeRequested(
      reporterId: 'user1',
      reporterName: 'Alice',
      respondentId: 'user2',
      reason: 'Agreement Violation',
      description: 'Did not fulfill terms',
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeCreated] on success',
      build: () {
        when(() => mockCreateDispute(any()))
            .thenAnswer((_) async => Right(tDispute));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        isA<DisputeCreated>(),
      ],
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeError] on failure',
      build: () {
        when(() => mockCreateDispute(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        DisputeError(message: 'Failed to create dispute'),
      ],
    );
  });

  group('ResolveDisputeRequested', () {
    final event = ResolveDisputeRequested(
      disputeId: 'dispute1',
      resolution: 'Resolved',
      resolvedBy: 'admin1',
      newStatus: 'resolved',
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeResolved] on success',
      build: () {
        when(() => mockResolveDispute(any()))
            .thenAnswer((_) async => Right(tDispute));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        isA<DisputeResolved>(),
      ],
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeError] on failure',
      build: () {
        when(() => mockResolveDispute(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        DisputeError(message: 'Failed to resolve dispute'),
      ],
    );
  });

  group('AppealDecisionRequested', () {
    final event = AppealDecisionRequested(
      disputeId: 'dispute1',
      appealReason: 'Unfair decision',
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeAppealed] on success',
      build: () {
        when(() => mockAppealDecision(any()))
            .thenAnswer((_) async => Right(tDispute));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        isA<DisputeAppealed>(),
      ],
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeError] on failure',
      build: () {
        when(() => mockAppealDecision(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        DisputeError(message: 'Failed to appeal decision'),
      ],
    );
  });

  group('FetchDisputesRequested', () {
    final event = FetchDisputesRequested(userId: 'user1');

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputesLoaded] on success',
      build: () {
        when(() => mockRepository.getDisputesForUser(any()))
            .thenAnswer((_) async => Right(tDisputes));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        isA<DisputesLoaded>(),
      ],
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeError] on failure',
      build: () {
        when(() => mockRepository.getDisputesForUser(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        DisputeError(message: 'Failed to fetch disputes'),
      ],
    );
  });

  group('FetchDisputeByIdRequested', () {
    final event = FetchDisputeByIdRequested(disputeId: 'dispute1');

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeDetailLoaded] on success',
      build: () {
        when(() => mockRepository.getDisputeById(any()))
            .thenAnswer((_) async => Right(tDispute));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        isA<DisputeDetailLoaded>(),
      ],
    );

    blocTest<DisputeBloc, DisputeState>(
      'emits [DisputeLoading, DisputeError] on failure',
      build: () {
        when(() => mockRepository.getDisputeById(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        DisputeLoading(),
        DisputeError(message: 'Failed to fetch dispute'),
      ],
    );
  });
}
