import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/data/datasources/agreement_remote_datasource.dart';
import 'package:myapp/features/agreements/data/models/agreement_model.dart';
import 'package:myapp/features/agreements/data/repository/agreement_repository_impl.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';

class MockAgreementRemoteDataSource extends Mock
    implements AgreementRemoteDataSource {}

void main() {
  late AgreementRepositoryImpl repository;
  late MockAgreementRemoteDataSource mockRemote;

  setUpAll(() {
    registerFallbackValue(AgreementModel(
      id: '',
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
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRemote = MockAgreementRemoteDataSource();
    repository = AgreementRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('createAgreement', () {
    test('should create agreement on success', () async {
      when(() => mockRemote.createAgreement(any()))
          .thenAnswer((_) async {});

      final result = await repository.createAgreement(
        'user1',
        'User One',
        'user2',
        'User Two',
        'skill1',
        'Flutter',
        'skill2',
        'Photography',
        '4 weeks',
        '1x/week',
        4,
        null,
      );

      expect(result.isRight(), true);
      final agreement = result.getOrElse(() => throw 'unexpected');
      expect(agreement.initiatorId, 'user1');
      expect(agreement.partnerId, 'user2');
      expect(agreement.duration, '4 weeks');
      expect(agreement.frequency, '1x/week');
      expect(agreement.sessionsCount, 4);
      expect(agreement.status, AgreementStatus.pending);
      verify(() => mockRemote.createAgreement(any())).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.createAgreement(any()))
          .thenThrow(ServerException());

      final result = await repository.createAgreement(
        'user1', 'User One', 'user2', 'User Two',
        'skill1', 'Flutter', 'skill2', 'Photography',
        '4 weeks', '1x/week', 4, null,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.createAgreement(any()))
          .thenThrow(Exception());

      final result = await repository.createAgreement(
        'user1', 'User One', 'user2', 'User Two',
        'skill1', 'Flutter', 'skill2', 'Photography',
        '4 weeks', '1x/week', 4, null,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('acceptAgreement', () {
    test('should accept agreement on success', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.acceptAgreement('agreement1', 'user2');

      expect(result.isRight(), true);
      verify(() => mockRemote.updateAgreement('agreement1', any())).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.acceptAgreement('agreement1', 'user2');

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenThrow(Exception());

      final result = await repository.acceptAgreement('agreement1', 'user2');

      expect(result.isLeft(), true);
    });
  });

  group('modifyAgreement', () {
    final tUpdatedModel = AgreementModel(
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

    test('should modify agreement on success', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getAgreement(any()))
          .thenAnswer((_) async => tUpdatedModel);

      final result = await repository.modifyAgreement(
        'agreement1', 'user1', '6 weeks', '2x/week', 12, 'Extended terms',
      );

      expect(result.isRight(), true);
      final agreement = result.getOrElse(() => throw 'unexpected');
      expect(agreement.duration, '6 weeks');
      expect(agreement.frequency, '2x/week');
      expect(agreement.sessionsCount, 12);
      expect(agreement.status, AgreementStatus.modified);
    });

    test('should return ServerFailure when update throws', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.modifyAgreement(
        'agreement1', 'user1', '6 weeks', '2x/week', 12, 'Extended terms',
      );

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when getAgreement returns null', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getAgreement(any()))
          .thenAnswer((_) async => null);

      final result = await repository.modifyAgreement(
        'agreement1', 'user1', '6 weeks', '2x/week', 12, 'Extended terms',
      );

      expect(result.isLeft(), true);
    });
  });

  group('cancelAgreement', () {
    test('should cancel agreement on success', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.cancelAgreement('agreement1', 'user1');

      expect(result.isRight(), true);
      verify(() => mockRemote.updateAgreement('agreement1', any())).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateAgreement(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.cancelAgreement('agreement1', 'user1');

      expect(result.isLeft(), true);
    });
  });

  group('viewAgreements', () {
    final tModel = AgreementModel(
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
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    test('should view agreements on success', () async {
      when(() => mockRemote.fetchAgreementsForUser(any()))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.viewAgreements('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<AgreementEntity>>());
      verify(() => mockRemote.fetchAgreementsForUser('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchAgreementsForUser(any()))
          .thenThrow(ServerException());

      final result = await repository.viewAgreements('user1');

      expect(result.isLeft(), true);
    });
  });

  group('getAgreementById', () {
    final tModel = AgreementModel(
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
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    test('should get agreement by id on success', () async {
      when(() => mockRemote.getAgreement(any()))
          .thenAnswer((_) async => tModel);

      final result = await repository.getAgreementById('agreement1');

      expect(result.isRight(), true);
      verify(() => mockRemote.getAgreement('agreement1')).called(1);
    });

    test('should return ServerFailure when remote returns null', () async {
      when(() => mockRemote.getAgreement(any()))
          .thenAnswer((_) async => null);

      final result = await repository.getAgreementById('agreement1');

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getAgreement(any()))
          .thenThrow(ServerException());

      final result = await repository.getAgreementById('agreement1');

      expect(result.isLeft(), true);
    });
  });
}
