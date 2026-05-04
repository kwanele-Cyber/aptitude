import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class SkillModel extends SkillEntity {
  const SkillModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.type,
    required super.level,
    required super.format,
    required super.userId,
    super.tags,
    super.createdAt,
    super.updatedAt,
    super.archivedAt,
  });

  factory SkillModel.fromJson(String id, Map<String, dynamic> json) {
    return SkillModel(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      type: parseType(json['type'] as String?),
      level: parseLevel(json['level'] as String?),
      format: parseFormat(json['format'] as String?),
      userId: json['userId'] as String? ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.tryParse(json['archivedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type.name,
      'level': level.name,
      'format': format.name,
      'userId': userId,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }

  static SkillType parseType(String? type) {
    switch (type) {
      case 'request':
        return SkillType.request;
      default:
        return SkillType.offer;
    }
  }

  static SkillLevel parseLevel(String? level) {
    switch (level) {
      case 'intermediate':
        return SkillLevel.intermediate;
      case 'advanced':
        return SkillLevel.advanced;
      default:
        return SkillLevel.beginner;
    }
  }

  static SkillFormat parseFormat(String? format) {
    switch (format) {
      case 'inPerson':
        return SkillFormat.inPerson;
      case 'both':
        return SkillFormat.both;
      default:
        return SkillFormat.online;
    }
  }
}
