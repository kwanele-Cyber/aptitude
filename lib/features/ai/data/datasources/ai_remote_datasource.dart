import 'package:myapp/features/ai/data/models/behavior_flag_model.dart';
import 'package:myapp/features/ai/data/models/match_optimization_model.dart';
import 'package:myapp/features/ai/data/models/session_prediction_model.dart';
import 'package:myapp/features/ai/data/models/skill_recommendation_model.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';

abstract class AiRemoteDataSource {
  Future<List<SkillRecommendationModel>> getSkillRecommendations(
      String userId);
  Future<List<BehaviorFlagModel>> analyzeBehavior(String userId);
  Future<List<MatchOptimizationModel>> getMatchOptimizations(String userId);
  Future<SessionPredictionModel> predictSessionQuality(String matchId);
}

