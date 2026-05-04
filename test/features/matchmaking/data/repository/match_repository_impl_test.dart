import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource.dart';
import 'package:myapp/features/matchmaking/data/models/match_model.dart';
import 'package:myapp/features/matchmaking/data/repository/match_repository_impl.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class MockMatchRemoteDataSource extends Mock
    implements MatchRemoteDataSource {}

final tMatchModel = MatchModel(
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
  late MatchRepositoryImpl repository;
  late MockMatchRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockMatchRemoteDataSource();
    repository = MatchRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('generateMatches', () {
    test('should generate matches on success', () async {
      when(() => mockRemote.generateMatches(any(), any()))
          .thenAnswer((_) async => [tMatchModel]);

      final result = await repository.generateMatches('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<MatchEntity>>());
      verify(() => mockRemote.generateMatches('user1', [])).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.generateMatches(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.generateMatches('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.generateMatches(any(), any()))
          .thenThrow(Exception());

      final result = await repository.generateMatches('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateMatchStatus', () {
    test('should update match status on success', () async {
      when(() => mockRemote.updateMatchStatus(any(), any()))
          .thenAnswer((_) async {});

      final result =
          await repository.updateMatchStatus('match1', MatchStatus.accepted);

      expect(result.isRight(), true);
      verify(() => mockRemote.updateMatchStatus('match1', {
        'status': 'accepted',
      })).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateMatchStatus(any(), any()))
          .thenThrow(ServerException());

      final result =
          await repository.updateMatchStatus('match1', MatchStatus.accepted);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateMatchStatus(any(), any()))
          .thenThrow(Exception());

      final result =
          await repository.updateMatchStatus('match1', MatchStatus.accepted);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('saveMatch', () {
    test('should save match on success', () async {
      when(() => mockRemote.updateMatchStatus(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.saveMatch('match1');

      expect(result.isRight(), true);
      verify(() => mockRemote.updateMatchStatus('match1', {
        'saved': true,
      })).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateMatchStatus(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.saveMatch('match1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateMatchStatus(any(), any()))
          .thenThrow(Exception());

      final result = await repository.saveMatch('match1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchMatchHistory', () {
    test('should fetch match history on success', () async {
      when(() => mockRemote.fetchMatchesForUser(any()))
          .thenAnswer((_) async => [tMatchModel]);

      final result = await repository.fetchMatchHistory('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<MatchEntity>>());
      verify(() => mockRemote.fetchMatchesForUser('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchMatchesForUser(any()))
          .thenThrow(ServerException());

      final result = await repository.fetchMatchHistory('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchMatchesForUser(any()))
          .thenThrow(Exception());

      final result = await repository.fetchMatchHistory('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
