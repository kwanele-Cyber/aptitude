import 'package:myapp/features/matchmaking/data/models/match_model.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';

abstract class MatchRemoteDataSource {
  Future<List<MatchModel>> generateMatches(
      String userId, List<SkillModel> allSkills);
  Future<void> saveMatch(MatchModel match);
  Future<void> updateMatchStatus(String matchId, Map<String, dynamic> data);
  Future<List<MatchModel>> fetchMatchesForUser(String userId);
}

class MatchRemoteDataSourceMock implements MatchRemoteDataSource {
  @override
  Future<List<MatchModel>> generateMatches(
      String userId, List<SkillModel> allSkills) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<void> saveMatch(MatchModel match) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateMatchStatus(String matchId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<List<MatchModel>> fetchMatchesForUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
