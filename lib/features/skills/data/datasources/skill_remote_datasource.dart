import 'package:myapp/features/skills/data/models/saved_search_model.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

abstract class SkillRemoteDataSource {
  Future<SkillModel> createSkill(Map<String, dynamic> data);
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data);
  Future<void> deleteSkill(String id);
  Future<List<SkillModel>> fetchUserSkills(String uid);
  Future<SkillModel> getSkillById(String id);
  Future<void> archiveSkill(String id);
  Future<void> restoreSkill(String id);
  Future<List<SkillModel>> searchSkills(String query);
  Future<List<SkillModel>> fetchAllSkills();
  Future<void> saveSearch(Map<String, dynamic> data);
  Future<List<SavedSearchModel>> fetchSavedSearches(String uid);
  Future<void> deleteSavedSearch(String id);
}

