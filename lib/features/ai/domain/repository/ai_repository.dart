import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';

abstract class AiRepository {
  Future<Either<Failure, List<SkillRecommendationEntity>>>
      getSkillRecommendations(String userId);
  Future<Either<Failure, List<BehaviorFlagEntity>>> analyzeBehavior(
      String userId);
  Future<Either<Failure, List<MatchOptimizationEntity>>> getMatchOptimizations(
      String userId);
  Future<Either<Failure, SessionPredictionEntity>> predictSessionQuality(
      String matchId);
}
