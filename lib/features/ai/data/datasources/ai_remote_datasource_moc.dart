import 'package:myapp/features/ai/data/models/behavior_flag_model.dart';
import 'package:myapp/features/ai/data/models/match_optimization_model.dart';
import 'package:myapp/features/ai/data/models/session_prediction_model.dart';
import 'package:myapp/features/ai/data/models/skill_recommendation_model.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/data/datasources/ai_remote_datasource.dart';

class AiRemoteDataSourceMock implements AiRemoteDataSource {
  @override
  Future<List<SkillRecommendationModel>> getSkillRecommendations(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SkillRecommendationModel(
        id: 'rec_1',
        skillTitle: 'Data Science Fundamentals',
        category: 'Technology',
        reason: 'Your Python skill pairs well with data analysis',
        confidenceScore: 0.87,
        type: RecommendationType.learn,
      ),
    ];
  }

  @override
  Future<List<BehaviorFlagModel>> analyzeBehavior(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<List<MatchOptimizationModel>> getMatchOptimizations(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MatchOptimizationModel(
        id: 'opt_1',
        metric: 'match_score_accuracy',
        currentValue: 0.72,
        suggestedValue: 0.85,
        insight: 'Including session history improves accuracy by 13%',
        impact: 'high',
      ),
    ];
  }

  @override
  Future<SessionPredictionModel> predictSessionQuality(
      String matchId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SessionPredictionModel(
      matchId: matchId,
      predictedQuality: 0.82,
      confidence: 0.76,
      keyFactors: [
        'complementary_skill_levels',
        'availability_overlap',
        'historical_completion_rate',
      ],
    );
  }
}
