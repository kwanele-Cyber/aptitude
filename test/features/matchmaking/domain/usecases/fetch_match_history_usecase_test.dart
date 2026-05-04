import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';
import 'package:myapp/features/matchmaking/domain/usecases/fetch_match_history_usecase.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

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
  late MockMatchRepository mockRepository;
  late FetchMatchHistoryUseCase useCase;

  setUp(() {
    mockRepository = MockMatchRepository();
    useCase = FetchMatchHistoryUseCase(repository: mockRepository);
  });

  group('FetchMatchHistoryUseCase', () {
    const params = FetchMatchHistoryParams(userId: 'user1');

    test('should fetch match history on success', () async {
      when(() => mockRepository.fetchMatchHistory(any()))
          .thenAnswer((_) async => Right([tMatch]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.fetchMatchHistory('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.fetchMatchHistory(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
