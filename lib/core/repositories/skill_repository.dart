import 'package:myapp/core/models/skill_model.dart';

abstract class SkillRepository {
  Future<void> createSkill({
    required SkillModel skill,
    required String userId,
    required bool isOffer,
  });
  Future<void> updateSkill({
    required SkillModel skill,
    required String userId,
  });
  Future<void> deleteSkill({
    required String skillId,
    required String userId,
  });
  Future<List<SkillModel>> searchSkills(String query);
  Future<List<SkillModel>> getRecentSkills({int limit = 20});
  Future<List<SkillModel>> getSkillsByUser(String userId);
}
