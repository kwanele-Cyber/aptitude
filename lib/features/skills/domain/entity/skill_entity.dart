enum SkillType { offer, request }

enum SkillLevel { beginner, intermediate, advanced }

enum SkillFormat { online, inPerson, both }

class SkillEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final SkillType type;
  final SkillLevel level;
  final SkillFormat format;
  final String userId;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SkillEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.type = SkillType.offer,
    required this.level,
    required this.format,
    required this.userId,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });
}
