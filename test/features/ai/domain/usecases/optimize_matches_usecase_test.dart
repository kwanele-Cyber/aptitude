import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';
import 'package:myapp/features/ai/domain/usecases/optimize_matches_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

final tOptimization = MatchOptimizationEntity(
  id: 'opt_1',
  metric: 'match_score_accuracy',
  currentValue: 0.72,
  suggestedValue: 0.85,
  insight: 'Including session history improves accuracy by 13%',
  impact: 'high',
);

void main() {
  late MockAiRepository mockRepository;
  late OptimizeMatchesUseCase useCase;

  setUp(() {
    mockRepository = MockAiRepository();
    useCase = OptimizeMatchesUseCase(repository: mockRepository);
  });

  group('OptimizeMatchesUseCase', () {
    const params = OptimizeMatchesParams(userId: 'user1');

    test('should return match optimizations on success', () async {
      when(() => mockRepository.getMatchOptimizations(any()))
          .thenAnswer((_) async => Right([tOptimization]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getMatchOptimizations('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getMatchOptimizations(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
