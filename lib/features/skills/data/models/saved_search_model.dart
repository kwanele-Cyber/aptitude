import 'package:myapp/features/skills/domain/entity/saved_search_entity.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class SavedSearchModel extends SavedSearchEntity {
  const SavedSearchModel({
    required super.id,
    required super.userId,
    required super.query,
    super.category,
    super.level,
    super.format,
    super.type,
    required super.createdAt,
  });

  factory SavedSearchModel.fromJson(
      String key, Map<String, dynamic> json) {
    return SavedSearchModel(
      id: key,
      userId: json['userId'] as String? ?? '',
      query: json['query'] as String? ?? '',
      category: json['category'] as String?,
      level: json['level'] != null
          ? _parseLevel(json['level'] as String)
          : null,
      format: json['format'] != null
          ? _parseFormat(json['format'] as String)
          : null,
      type: json['type'] != null
          ? _parseType(json['type'] as String)
          : null,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'query': query,
      'category': category,
      'level': level?.name,
      'format': format?.name,
      'type': type?.name,
      'createdAt': createdAt,
    };
  }

  static SkillLevel _parseLevel(String value) {
    return SkillLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillLevel.beginner,
    );
  }

  static SkillFormat _parseFormat(String value) {
    return SkillFormat.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillFormat.online,
    );
  }

  static SkillType _parseType(String value) {
    return SkillType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillType.offer,
    );
  }
}
