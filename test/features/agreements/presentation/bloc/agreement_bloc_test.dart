import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/usecases/accept_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/cancel_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/create_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/get_agreement_by_id_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/modify_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/view_agreements_usecase.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_bloc.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_event.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCreateAgreementUseCase extends Mock
    implements CreateAgreementUseCase {}

class MockAcceptAgreementUseCase extends Mock
    implements AcceptAgreementUseCase {}

class MockModifyAgreementUseCase extends Mock
    implements ModifyAgreementUseCase {}

class MockCancelAgreementUseCase extends Mock
    implements CancelAgreementUseCase {}

class MockViewAgreementsUseCase extends Mock
    implements ViewAgreementsUseCase {}

class MockGetAgreementByIdUseCase extends Mock
    implements GetAgreementByIdUseCase {}

final tAgreement = AgreementEntity(
  id: 'agreement1',
  initiatorId: 'user1',
  initiatorName: 'User One',
  partnerId: 'user2',
  partnerName: 'User Two',
  initiatorSkillId: 'skill1',
  initiatorSkillTitle: 'Flutter',
  partnerSkillId: 'skill2',
  partnerSkillTitle: 'Photography',
  status: AgreementStatus.pending,
  duration: '4 weeks',
  frequency: '1x/week',
  sessionsCount: 4,
  notes: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

void main() {
  late AgreementBloc bloc;
  late MockCreateAgreementUseCase mockCreateUseCase;
  late MockAcceptAgreementUseCase mockAcceptUseCase;
  late MockModifyAgreementUseCase mockModifyUseCase;
  late MockCancelAgreementUseCase mockCancelUseCase;
  late MockViewAgreementsUseCase mockViewUseCase;
  late MockGetAgreementByIdUseCase mockGetByIdUseCase;

  setUpAll(() {
    registerFallbackValue(const CreateAgreementParams(
      initiatorId: '',
      initiatorName: '',
      partnerId: '',
      partnerName: '',
      initiatorSkillId: '',
      initiatorSkillTitle: '',
      partnerSkillId: '',
      partnerSkillTitle: '',
      duration: '',
      frequency: '',
      sessionsCount: 1,
    ));
    registerFallbackValue(const AcceptAgreementParams(
      agreementId: '',
      userId: '',
    ));
    registerFallbackValue(const ModifyAgreementParams(
      agreementId: '',
      userId: '',
      duration: '',
      frequency: '',
      sessionsCount: 1,
    ));
    registerFallbackValue(const CancelAgreementParams(
      agreementId: '',
      userId: '',
    ));
    registerFallbackValue(const ViewAgreementsParams(userId: ''));
    registerFallbackValue(const GetAgreementByIdParams(agreementId: ''));
  });

  setUp(() {
    mockCreateUseCase = MockCreateAgreementUseCase();
    mockAcceptUseCase = MockAcceptAgreementUseCase();
    mockModifyUseCase = MockModifyAgreementUseCase();
    mockCancelUseCase = MockCancelAgreementUseCase();
    mockViewUseCase = MockViewAgreementsUseCase();
    mockGetByIdUseCase = MockGetAgreementByIdUseCase();

    bloc = AgreementBloc(
      createAgreementUseCase: mockCreateUseCase,
      acceptAgreementUseCase: mockAcceptUseCase,
      modifyAgreementUseCase: mockModifyUseCase,
      cancelAgreementUseCase: mockCancelUseCase,
      viewAgreementsUseCase: mockViewUseCase,
      getAgreementByIdUseCase: mockGetByIdUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateAgreementRequested', () {
    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementCreated] on success',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Right(tAgreement));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateAgreementRequested(
        initiatorId: 'user1',
        initiatorName: 'User One',
        partnerId: 'user2',
        partnerName: 'User Two',
        initiatorSkillId: 'skill1',
        initiatorSkillTitle: 'Flutter',
        partnerSkillId: 'skill2',
        partnerSkillTitle: 'Photography',
        duration: '4 weeks',
        frequency: '1x/week',
        sessionsCount: 4,
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementCreated>().having(
          (s) => s.agreement.id,
          'agreement id',
          'agreement1',
        ),
      ],
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementError] on failure',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateAgreementRequested(
        initiatorId: 'user1',
        initiatorName: 'User One',
        partnerId: 'user2',
        partnerName: 'User Two',
        initiatorSkillId: 'skill1',
        initiatorSkillTitle: 'Flutter',
        partnerSkillId: 'skill2',
        partnerSkillTitle: 'Photography',
        duration: '4 weeks',
        frequency: '1x/week',
        sessionsCount: 4,
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementError>(),
      ],
    );
  });

  group('AcceptAgreementRequested', () {
    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementActionSuccess] on success',
      build: () {
        when(() => mockAcceptUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(AcceptAgreementRequested(
        agreementId: 'agreement1',
        userId: 'user2',
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementActionSuccess>(),
      ],
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementError] on failure',
      build: () {
        when(() => mockAcceptUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AcceptAgreementRequested(
        agreementId: 'agreement1',
        userId: 'user2',
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementError>(),
      ],
    );
  });

  group('ModifyAgreementRequested', () {
    final tModifiedAgreement = AgreementEntity(
      id: 'agreement1',
      initiatorId: 'user1',
      initiatorName: 'User One',
      partnerId: 'user2',
      partnerName: 'User Two',
      initiatorSkillId: 'skill1',
      initiatorSkillTitle: 'Flutter',
      partnerSkillId: 'skill2',
      partnerSkillTitle: 'Photography',
      status: AgreementStatus.modified,
      duration: '6 weeks',
      frequency: '2x/week',
      sessionsCount: 12,
      notes: 'Extended terms',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 15),
      modifiedBy: 'user1',
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementDetailLoaded] on success',
      build: () {
        when(() => mockModifyUseCase(any()))
            .thenAnswer((_) async => Right(tModifiedAgreement));
        return bloc;
      },
      act: (bloc) => bloc.add(ModifyAgreementRequested(
        agreementId: 'agreement1',
        userId: 'user1',
        duration: '6 weeks',
        frequency: '2x/week',
        sessionsCount: 12,
        notes: 'Extended terms',
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementDetailLoaded>().having(
          (s) => s.agreement.duration,
          'duration',
          '6 weeks',
        ),
      ],
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementError] on failure',
      build: () {
        when(() => mockModifyUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ModifyAgreementRequested(
        agreementId: 'agreement1',
        userId: 'user1',
        duration: '6 weeks',
        frequency: '2x/week',
        sessionsCount: 12,
        notes: 'Extended terms',
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementError>(),
      ],
    );
  });

  group('CancelAgreementRequested', () {
    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementActionSuccess] on success',
      build: () {
        when(() => mockCancelUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(CancelAgreementRequested(
        agreementId: 'agreement1',
        userId: 'user1',
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementActionSuccess>(),
      ],
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementError] on failure',
      build: () {
        when(() => mockCancelUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(CancelAgreementRequested(
        agreementId: 'agreement1',
        userId: 'user1',
      )),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementError>(),
      ],
    );
  });

  group('FetchAgreementsRequested', () {
    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementsLoaded] on success',
      build: () {
        when(() => mockViewUseCase(any()))
            .thenAnswer((_) async => Right([tAgreement]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchAgreementsRequested(userId: 'user1')),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementsLoaded>().having(
          (s) => s.agreements,
          'agreements',
          [tAgreement],
        ),
      ],
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementError] on failure',
      build: () {
        when(() => mockViewUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchAgreementsRequested(userId: 'user1')),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementError>(),
      ],
    );
  });

  group('FetchAgreementByIdRequested', () {
    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementDetailLoaded] on success',
      build: () {
        when(() => mockGetByIdUseCase(any()))
            .thenAnswer((_) async => Right(tAgreement));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchAgreementByIdRequested(agreementId: 'agreement1')),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementDetailLoaded>().having(
          (s) => s.agreement.id,
          'agreement id',
          'agreement1',
        ),
      ],
    );

    blocTest<AgreementBloc, AgreementState>(
      'emits [AgreementLoading, AgreementError] on failure',
      build: () {
        when(() => mockGetByIdUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchAgreementByIdRequested(agreementId: 'agreement1')),
      expect: () => [
        isA<AgreementLoading>(),
        isA<AgreementError>(),
      ],
    );
  });
}
