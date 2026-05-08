import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:myapp/features/ai/data/models/skill_recommendation_model.dart';
import 'package:myapp/features/ai/data/models/behavior_flag_model.dart';
import 'package:myapp/features/ai/data/models/match_optimization_model.dart';
import 'package:myapp/features/ai/data/models/session_prediction_model.dart';
import 'package:myapp/features/ai/data/repository/ai_repository_impl.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';

class MockAiRemoteDataSource extends Mock implements AiRemoteDataSource {}

void main() {
  late MockAiRemoteDataSource mockDataSource;
  late AiRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAiRemoteDataSource();
    repository = AiRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('getSkillRecommendations', () {
    final tModel = SkillRecommendationModel(
      id: 'rec_1',
      skillTitle: 'Data Science',
      category: 'Technology',
      reason: 'Pairs well with Python',
      confidenceScore: 0.87,
      type: RecommendationType.learn,
    );

    test('should return recommendations on success', () async {
      when(() => mockDataSource.getSkillRecommendations(any()))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getSkillRecommendations('user1');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r, [tModel]),
      );
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockDataSource.getSkillRecommendations(any()))
          .thenThrow(const ServerException());

      final result = await repository.getSkillRecommendations('user1');

      expect(result, Left(ServerFailure()));
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockDataSource.getSkillRecommendations(any()))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getSkillRecommendations('user1');

      expect(result, Left(ServerFailure()));
    });
  });

  group('analyzeBehavior', () {
    final tModel = BehaviorFlagModel(
      id: 'flag_1',
      userId: 'user1',
      type: FlagType.unusualLoginLocation,
      severity: FlagSeverity.high,
      description: 'Login from unusual location',
      timestamp: DateTime(2025, 1, 1),
    );

    test('should return behavior flags on success', () async {
      when(() => mockDataSource.analyzeBehavior(any()))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.analyzeBehavior('user1');

      expect(result.isRight(), true);
    });

    test('should return ServerFailure on exception', () async {
      when(() => mockDataSource.analyzeBehavior(any()))
          .thenThrow(const ServerException());

      final result = await repository.analyzeBehavior('user1');

      expect(result, Left(ServerFailure()));
    });
  });

  group('getMatchOptimizations', () {
    final tModel = MatchOptimizationModel(
      id: 'opt_1',
      metric: 'match_score_accuracy',
      currentValue: 0.72,
      suggestedValue: 0.85,
      insight: 'Including session history improves accuracy by 13%',
      impact: 'high',
    );

    test('should return optimizations on success', () async {
      when(() => mockDataSource.getMatchOptimizations(any()))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getMatchOptimizations('user1');

      expect(result.isRight(), true);
    });

    test('should return ServerFailure on exception', () async {
      when(() => mockDataSource.getMatchOptimizations(any()))
          .thenThrow(const ServerException());

      final result = await repository.getMatchOptimizations('user1');

      expect(result, Left(ServerFailure()));
    });
  });

  group('predictSessionQuality', () {
    final tModel = SessionPredictionModel(
      matchId: 'match1',
      predictedQuality: 0.82,
      confidence: 0.76,
      keyFactors: ['complementary_skill_levels'],
    );

    test('should return prediction on success', () async {
      when(() => mockDataSource.predictSessionQuality(any()))
          .thenAnswer((_) async => tModel);

      final result = await repository.predictSessionQuality('match1');

      expect(result.isRight(), true);
    });

    test('should return ServerFailure on exception', () async {
      when(() => mockDataSource.predictSessionQuality(any()))
          .thenThrow(const ServerException());

      final result = await repository.predictSessionQuality('match1');

      expect(result, Left(ServerFailure()));
    });
  });
}
