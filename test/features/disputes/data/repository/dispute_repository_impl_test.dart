import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/data/datasources/dispute_remote_datasource.dart';
import 'package:myapp/features/disputes/data/models/dispute_model.dart';
import 'package:myapp/features/disputes/data/repository/dispute_repository_impl.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';

class MockDisputeRemoteDataSource extends Mock
    implements DisputeRemoteDataSource {}

final tDisputeModel = DisputeModel(
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

void main() {
  late DisputeRepositoryImpl repository;
  late MockDisputeRemoteDataSource mockRemote;

  setUpAll(() {
    registerFallbackValue(tDisputeModel);
    registerFallbackValue(DisputeStatus.pending);
  });

  setUp(() {
    mockRemote = MockDisputeRemoteDataSource();
    repository = DisputeRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('reportUser', () {
    test('should create dispute on success', () async {
      when(() => mockRemote.createDispute(any()))
          .thenAnswer((_) async {});

      final result = await repository.reportUser(
        reporterId: 'user1',
        reporterName: 'Alice',
        reportedUserId: 'user2',
        reportedUserName: 'Bob',
        reason: 'Harassment',
        description: 'Inappropriate messages',
      );

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tDisputeModel), isA<DisputeEntity>());
      verify(() => mockRemote.createDispute(any())).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.createDispute(any()))
          .thenThrow(ServerException());

      final result = await repository.reportUser(
        reporterId: 'user1',
        reporterName: 'Alice',
        reportedUserId: 'user2',
        reportedUserName: 'Bob',
        reason: 'Harassment',
        description: 'Inappropriate messages',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.createDispute(any())).thenThrow(Exception());

      final result = await repository.reportUser(
        reporterId: 'user1',
        reporterName: 'Alice',
        reportedUserId: 'user2',
        reportedUserName: 'Bob',
        reason: 'Harassment',
        description: 'Inappropriate messages',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('createDispute', () {
    test('should create dispute on success', () async {
      when(() => mockRemote.createDispute(any()))
          .thenAnswer((_) async {});

      final result = await repository.createDispute(
        reporterId: 'user1',
        reporterName: 'Alice',
        respondentId: 'user2',
        reason: 'Agreement Violation',
        description: 'Did not fulfill terms',
      );

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tDisputeModel), isA<DisputeEntity>());
      verify(() => mockRemote.createDispute(any())).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.createDispute(any()))
          .thenThrow(ServerException());

      final result = await repository.createDispute(
        reporterId: 'user1',
        reporterName: 'Alice',
        respondentId: 'user2',
        reason: 'Agreement Violation',
        description: 'Did not fulfill terms',
      );

      expect(result.isLeft(), true);
    });
  });

  group('resolveDispute', () {
    test('should resolve dispute on success', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => tDisputeModel);
      when(() => mockRemote.updateDispute(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => tDisputeModel);

      final result = await repository.resolveDispute(
        'dispute1',
        resolution: 'Resolved',
        resolvedBy: 'admin1',
        status: DisputeStatus.resolved,
      );

      expect(result.isRight(), true);
      verify(() => mockRemote.updateDispute('dispute1', any())).called(1);
    });

    test('should return ServerFailure when dispute not found', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => null);

      final result = await repository.resolveDispute(
        'dispute1',
        resolution: 'Resolved',
        resolvedBy: 'admin1',
        status: DisputeStatus.resolved,
      );

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => tDisputeModel);
      when(() => mockRemote.updateDispute(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.resolveDispute(
        'dispute1',
        resolution: 'Resolved',
        resolvedBy: 'admin1',
        status: DisputeStatus.resolved,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('appealDecision', () {
    test('should appeal on success', () async {
      final resolvedDispute = DisputeModel(
        id: 'dispute1',
        type: DisputeType.dispute,
        reporterId: 'user1',
        reporterName: 'Alice',
        respondentId: 'user2',
        reason: 'Agreement Violation',
        description: 'Did not fulfill terms',
        status: DisputeStatus.resolved,
        resolution: 'Resolved',
        resolvedBy: 'admin1',
        resolvedAt: DateTime(2024, 1, 16, 10, 0),
        createdAt: DateTime(2024, 1, 15, 10, 0),
        updatedAt: DateTime(2024, 1, 16, 10, 0),
      );

      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => resolvedDispute);
      when(() => mockRemote.updateDispute(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => resolvedDispute);

      final result = await repository.appealDecision(
        'dispute1',
        appealReason: 'Unfair decision',
      );

      expect(result.isRight(), true);
      verify(() => mockRemote.updateDispute('dispute1', any())).called(1);
    });

    test('should return ServerFailure when dispute not found', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => null);

      final result = await repository.appealDecision(
        'dispute1',
        appealReason: 'Unfair decision',
      );

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when dispute is not resolved', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => tDisputeModel);

      final result = await repository.appealDecision(
        'dispute1',
        appealReason: 'Unfair decision',
      );

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l.message, (r) => null),
        contains('cannot be appealed'),
      );
    });

    test('should return ServerFailure when remote throws on get', () async {
      when(() => mockRemote.getDispute(any()))
          .thenThrow(ServerException());

      final result = await repository.appealDecision(
        'dispute1',
        appealReason: 'Unfair decision',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getDisputesForUser', () {
    final disputes = [tDisputeModel];

    test('should fetch disputes on success', () async {
      when(() => mockRemote.fetchDisputesForUser(any()))
          .thenAnswer((_) async => disputes);

      final result = await repository.getDisputesForUser('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<DisputeEntity>>());
      verify(() => mockRemote.fetchDisputesForUser('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchDisputesForUser(any()))
          .thenThrow(ServerException());

      final result = await repository.getDisputesForUser('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getAllDisputes', () {
    final disputes = [tDisputeModel];

    test('should fetch all disputes on success', () async {
      when(() => mockRemote.fetchAllDisputes())
          .thenAnswer((_) async => disputes);

      final result = await repository.getAllDisputes();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<DisputeEntity>>());
      verify(() => mockRemote.fetchAllDisputes()).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchAllDisputes())
          .thenThrow(ServerException());

      final result = await repository.getAllDisputes();

      expect(result.isLeft(), true);
    });
  });

  group('getDisputeById', () {
    test('should fetch dispute on success', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => tDisputeModel);

      final result = await repository.getDisputeById('dispute1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tDisputeModel), isA<DisputeEntity>());
      verify(() => mockRemote.getDispute('dispute1')).called(1);
    });

    test('should return ServerFailure when not found', () async {
      when(() => mockRemote.getDispute(any()))
          .thenAnswer((_) async => null);

      final result = await repository.getDisputeById('dispute1');

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getDispute(any()))
          .thenThrow(ServerException());

      final result = await repository.getDisputeById('dispute1');

      expect(result.isLeft(), true);
    });
  });
}
