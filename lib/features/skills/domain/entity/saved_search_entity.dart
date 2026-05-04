import 'package:equatable/equatable.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class SavedSearchEntity extends Equatable {
  final String id;
  final String userId;
  final String query;
  final String? category;
  final SkillLevel? level;
  final SkillFormat? format;
  final SkillType? type;
  final String createdAt;

  const SavedSearchEntity({
    required this.id,
    required this.userId,
    required this.query,
    this.category,
    this.level,
    this.format,
    this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, query, category, level, format, type, createdAt];
}
