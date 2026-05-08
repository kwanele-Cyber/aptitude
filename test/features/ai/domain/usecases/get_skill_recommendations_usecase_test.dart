import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';
import 'package:myapp/features/ai/domain/usecases/get_skill_recommendations_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

final tRecommendation = SkillRecommendationEntity(
  id: 'rec_1',
  skillTitle: 'Data Science',
  category: 'Technology',
  reason: 'Pairs well with Python',
  confidenceScore: 0.87,
  type: RecommendationType.learn,
);

void main() {
  late MockAiRepository mockRepository;
  late GetSkillRecommendationsUseCase useCase;

  setUp(() {
    mockRepository = MockAiRepository();
    useCase = GetSkillRecommendationsUseCase(repository: mockRepository);
  });

  group('GetSkillRecommendationsUseCase', () {
    const params = GetSkillRecommendationsParams(userId: 'user1');

    test('should return recommendations on success', () async {
      when(() => mockRepository.getSkillRecommendations(any()))
          .thenAnswer((_) async => Right([tRecommendation]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getSkillRecommendations('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getSkillRecommendations(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
