import 'package:myapp/features/matchmaking/data/models/match_model.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';

abstract class MatchRemoteDataSource {
  Future<List<MatchModel>> generateMatches(
      String userId, List<SkillModel> allSkills);
  Future<void> saveMatch(MatchModel match);
  Future<void> updateMatchStatus(String matchId, Map<String, dynamic> data);
  Future<List<MatchModel>> fetchMatchesForUser(String userId);
  Future<void> saveFeedback(String matchId, Map<String, dynamic> data);
}

