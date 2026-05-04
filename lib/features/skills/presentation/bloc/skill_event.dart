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

class UpdateSkillRequested extends SkillEvent {
  final String id;
  final String title;
  final String description;
  final String category;
  final SkillType type;
  final SkillLevel level;
  final SkillFormat format;
  final List<String> tags;

  UpdateSkillRequested({
    required this.id,
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
      [id, title, description, category, type, level, format, tags];
}

class DeleteSkillRequested extends SkillEvent {
  final String id;

  DeleteSkillRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class FetchUserSkillsRequested extends SkillEvent {
  final String uid;

  FetchUserSkillsRequested({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class CloneSkillRequested extends SkillEvent {
  final String skillId;

  CloneSkillRequested({required this.skillId});

  @override
  List<Object?> get props => [skillId];
}

class ArchiveSkillRequested extends SkillEvent {
  final String id;

  ArchiveSkillRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class RestoreSkillRequested extends SkillEvent {
  final String id;

  RestoreSkillRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
