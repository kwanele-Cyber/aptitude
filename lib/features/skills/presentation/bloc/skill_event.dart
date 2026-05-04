import 'package:equatable/equatable.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

abstract class SkillEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSkillOfferRequested extends SkillEvent {
  final String title;
  final String description;
  final String category;
  final SkillType type;
  final SkillLevel level;
  final SkillFormat format;
  final List<String> tags;

  CreateSkillOfferRequested({
    required this.title,
    required this.description,
    required this.category,
    this.type = SkillType.offer,
    required this.level,
    required this.format,
    this.tags = const [],
  });

  @override
  List<Object?> get props =>
      [title, description, category, type, level, format, tags];
}
