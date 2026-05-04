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
}

class SkillRemoteDataSourceMock implements SkillRemoteDataSource {
  @override
  Future<SkillModel> createSkill(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return SkillModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      type: SkillModel.parseType(data['type'] as String?),
      level: SkillModel.parseLevel(data['level'] as String?),
      format: SkillModel.parseFormat(data['format'] as String?),
      userId: data['userId'] as String? ?? '',
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return SkillModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      type: SkillModel.parseType(data['type'] as String?),
      level: SkillModel.parseLevel(data['level'] as String?),
      format: SkillModel.parseFormat(data['format'] as String?),
      userId: data['userId'] as String? ?? '',
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  Future<void> deleteSkill(String id) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<List<SkillModel>> fetchUserSkills(String uid) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<SkillModel> getSkillById(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return SkillModel(
      id: id,
      title: 'Cloned Skill',
      description: 'Description',
      category: 'Tech',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
      userId: 'user1',
    );
  }

  @override
  Future<void> archiveSkill(String id) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> restoreSkill(String id) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<List<SkillModel>> searchSkills(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
