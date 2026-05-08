import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/data/datasources/trust_remote_datasource.dart';
import 'package:myapp/features/trust/data/models/trust_model.dart';
import 'package:myapp/features/trust/data/repository/trust_repository_impl.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';

class MockTrustRemoteDataSource extends Mock implements TrustRemoteDataSource {}

final tTrustModel = TrustModel(
  id: 'trust_user1',
  userId: 'user1',
  score: 75,
  factors: [],
  lastCalculated: DateTime(2025, 1, 1),
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

void main() {
  late TrustRepositoryImpl repository;
  late MockTrustRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockTrustRemoteDataSource();
    repository = TrustRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('calculateTrustScore', () {
    test('should calculate trust score on success', () async {
      when(() => mockRemote.calculateTrustScore(any()))
          .thenAnswer((_) async => tTrustModel);

      final result = await repository.calculateTrustScore('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tTrustModel), isA<TrustEntity>());
      verify(() => mockRemote.calculateTrustScore('user1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.calculateTrustScore(any()))
          .thenThrow(ServerException());

      final result = await repository.calculateTrustScore('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.calculateTrustScore(any()))
          .thenThrow(Exception());

      final result = await repository.calculateTrustScore('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateReputation', () {
    test('should update reputation on success', () async {
      when(() => mockRemote.updateReputation(any(), any(), any()))
          .thenAnswer((_) async => tTrustModel);

      final result =
          await repository.updateReputation('user1', 'session_completed', {
        'sessionId': 'session1',
      });

      expect(result.isRight(), true);
      verify(() => mockRemote.updateReputation(
          'user1', 'session_completed', {'sessionId': 'session1'})).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.updateReputation(any(), any(), any()))
          .thenThrow(ServerException());

      final result =
          await repository.updateReputation('user1', 'session_completed', {});

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getUsersAboveTrustThreshold', () {
    test('should return users above threshold on success', () async {
      when(() => mockRemote.getUsersAboveTrustThreshold(any()))
          .thenAnswer((_) async => ['user1', 'user2']);

      final result = await repository.getUsersAboveTrustThreshold(70);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), ['user1', 'user2']);
      verify(() => mockRemote.getUsersAboveTrustThreshold(70)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getUsersAboveTrustThreshold(any()))
          .thenThrow(ServerException());

      final result = await repository.getUsersAboveTrustThreshold(70);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getTrustProfile', () {
    test('should get trust profile on success', () async {
      when(() => mockRemote.getTrustProfile(any()))
          .thenAnswer((_) async => tTrustModel);

      final result = await repository.getTrustProfile('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tTrustModel), isA<TrustEntity>());
      verify(() => mockRemote.getTrustProfile('user1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getTrustProfile(any()))
          .thenThrow(ServerException());

      final result = await repository.getTrustProfile('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('submitAppeal', () {
    test('should submit appeal on success', () async {
      final tAppealModel = TrustAppealModel(
        id: 'appeal1',
        userId: 'user1',
        reason: 'My score dropped unfairly',
        status: AppealStatus.pending,
        createdAt: DateTime(2025, 1, 1),
      );
      when(() => mockRemote.submitAppeal(any(), any()))
          .thenAnswer((_) async => tAppealModel);

      final result =
          await repository.submitAppeal('user1', 'My score dropped unfairly');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tAppealModel), isA<TrustAppealEntity>());
      verify(() => mockRemote.submitAppeal('user1', 'My score dropped unfairly'))
          .called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.submitAppeal(any(), any()))
          .thenThrow(ServerException());

      final result =
          await repository.submitAppeal('user1', 'My score dropped unfairly');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getAppeals', () {
    test('should get appeals on success', () async {
      when(() => mockRemote.getAppeals(any()))
          .thenAnswer((_) async => []);

      final result = await repository.getAppeals('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty);
      verify(() => mockRemote.getAppeals('user1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getAppeals(any()))
          .thenThrow(ServerException());

      final result = await repository.getAppeals('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
