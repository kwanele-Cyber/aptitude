import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';
import 'package:myapp/features/matchmaking/domain/usecases/generate_matches_usecase.dart';
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
  late GenerateMatchesUseCase useCase;

  setUp(() {
    mockRepository = MockMatchRepository();
    useCase = GenerateMatchesUseCase(repository: mockRepository);
  });

  group('GenerateMatchesUseCase', () {
    const params = GenerateMatchesParams(userId: 'user1');

    test('should generate matches on success', () async {
      when(() => mockRepository.generateMatches(any()))
          .thenAnswer((_) async => Right([tMatch]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.generateMatches('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.generateMatches(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
