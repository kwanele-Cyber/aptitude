import 'package:myapp/core/network/deepseek_client.dart';
import 'package:myapp/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:myapp/features/ai/data/models/behavior_flag_model.dart';
import 'package:myapp/features/ai/data/models/match_optimization_model.dart';
import 'package:myapp/features/ai/data/models/session_prediction_model.dart';
import 'package:myapp/features/ai/data/models/skill_recommendation_model.dart';

class AiRemoteDataSourceDeepSeek implements AiRemoteDataSource {
  final DeepSeekClient _client;

  AiRemoteDataSourceDeepSeek({required DeepSeekClient client}) : _client = client;

  static const _recommendationPrompt = '''
You are a skill recommendation engine. Given a user's skill profile, recommend skills they should learn or teach.
Return a JSON object with a "recommendations" array. Each element has:
- id: unique string
- skillTitle: skill name
- category: skill category
- reason: brief explanation
- confidenceScore: number 0-1
- type: "learn" or "teach"
''';

  static const _behaviorPrompt = '''
You are a user behavior analysis system. Given a user's activity data, identify potential flags.
Return a JSON object with a "flags" array (empty if none). Each element has:
- id: unique string
- userId: the user id
- type: one of "unusualLoginLocation", "rapidMessageSpam", "suspiciousMatchPattern", "fakeReviewActivity", "accountTakeoverAttempt", "policyViolation"
- severity: one of "low", "medium", "high", "critical"
- description: explanation
- timestamp: ISO 8601 string of when the behavior occurred
- metadata: object with relevant details
''';

  static const _optimizationPrompt = '''
You are a match optimization analyst. Given a user's matchmaking profile, suggest optimizations.
Return a JSON object with an "optimizations" array. Each element has:
- id: unique string
- metric: the metric being optimized (e.g. "match_score_accuracy", "response_rate", "compatibility_range")
- currentValue: number 0-1 representing current performance
- suggestedValue: number 0-1 representing target performance
- insight: actionable advice
- impact: one of "low", "medium", "high"
''';

  static const _predictionPrompt = '''
You are a session quality predictor. Given match details between two users, predict the quality of their skill exchange session.
Return a JSON object with:
- matchId: the match id
- predictedQuality: number 0-1
- confidence: number 0-1
- keyFactors: array of strings describing factors influencing the prediction
''';

  @override
  Future<List<SkillRecommendationModel>> getSkillRecommendations(
      String userId) async {
    final result = await _client.chatCompletion(
      systemPrompt: _recommendationPrompt,
      userMessage: 'Analyze skill recommendations for user: $userId',
    );

    final list = result['recommendations'] as List;
    return list
        .map((e) => SkillRecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BehaviorFlagModel>> analyzeBehavior(String userId) async {
    final result = await _client.chatCompletion(
      systemPrompt: _behaviorPrompt,
      userMessage: 'Analyze behavior flags for user: $userId',
    );

    final list = result['flags'] as List?;
    if (list == null || list.isEmpty) return [];

    return list
        .map((e) => BehaviorFlagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MatchOptimizationModel>> getMatchOptimizations(
      String userId) async {
    final result = await _client.chatCompletion(
      systemPrompt: _optimizationPrompt,
      userMessage: 'Suggest match optimizations for user: $userId',
    );

    final list = result['optimizations'] as List;
    return list
        .map((e) => MatchOptimizationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SessionPredictionModel> predictSessionQuality(
      String matchId) async {
    final result = await _client.chatCompletion(
      systemPrompt: _predictionPrompt,
      userMessage: 'Predict session quality for match: $matchId',
    );

    return SessionPredictionModel.fromJson(result);
  }
}
