abstract class AiService {
  Future<List<Map<String, dynamic>>> getSkillRecommendations(String userId);
  Future<List<Map<String, dynamic>>> analyzeBehavior(String userId);
  Future<List<Map<String, dynamic>>> getMatchOptimizations(String userId);
  Future<Map<String, dynamic>> predictSessionQuality(String matchId);
}
