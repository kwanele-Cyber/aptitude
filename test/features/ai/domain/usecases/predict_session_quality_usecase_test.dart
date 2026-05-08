import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';
import 'package:myapp/features/ai/domain/usecases/predict_session_quality_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

final tPrediction = SessionPredictionEntity(
  matchId: 'match1',
  predictedQuality: 0.82,
  confidence: 0.76,
  keyFactors: [
    'complementary_skill_levels',
    'availability_overlap',
  ],
);

void main() {
  late MockAiRepository mockRepository;
  late PredictSessionQualityUseCase useCase;

  setUp(() {
    mockRepository = MockAiRepository();
    useCase = PredictSessionQualityUseCase(repository: mockRepository);
  });

  group('PredictSessionQualityUseCase', () {
    const params = PredictSessionQualityParams(matchId: 'match1');

    test('should return session prediction on success', () async {
      when(() => mockRepository.predictSessionQuality(any()))
          .thenAnswer((_) async => Right(tPrediction));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.predictSessionQuality('match1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.predictSessionQuality(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
