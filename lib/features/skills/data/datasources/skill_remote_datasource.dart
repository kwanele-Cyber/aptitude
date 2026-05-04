import 'package:myapp/features/skills/data/models/skill_model.dart';

abstract class SkillRemoteDataSource {
  Future<SkillModel> createSkill(Map<String, dynamic> data);
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data);
  Future<void> deleteSkill(String id);
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
}
