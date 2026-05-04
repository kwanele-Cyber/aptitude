import 'package:equatable/equatable.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

abstract class SkillState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SkillInitial extends SkillState {}

class SkillLoading extends SkillState {}

class SkillOfferCreated extends SkillState {
  final SkillEntity skill;

  SkillOfferCreated({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class SkillUpdated extends SkillState {
  final SkillEntity skill;

  SkillUpdated({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class SkillDeleted extends SkillState {
  final String id;

  SkillDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

class UserSkillsFetched extends SkillState {
  final List<SkillEntity> skills;

  UserSkillsFetched({required this.skills});

  @override
  List<Object?> get props => [skills];
}

class SkillCloned extends SkillState {
  final SkillEntity skill;

  SkillCloned({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class SkillArchived extends SkillState {
  final String id;

  SkillArchived({required this.id});

  @override
  List<Object?> get props => [id];
}

class SkillRestored extends SkillState {
  final String id;

  SkillRestored({required this.id});

  @override
  List<Object?> get props => [id];
}

class SkillsSearchCompleted extends SkillState {
  final String query;
  final List<SkillEntity> skills;

  SkillsSearchCompleted({required this.query, required this.skills});

  @override
  List<Object?> get props => [query, skills];
}

class SkillsFeedLoaded extends SkillState {
  final List<SkillEntity> skills;

  SkillsFeedLoaded({required this.skills});

  @override
  List<Object?> get props => [skills];
}

class SkillDetailsLoaded extends SkillState {
  final SkillEntity skill;

  SkillDetailsLoaded({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class SkillsFiltered extends SkillState {
  final List<SkillEntity> skills;
  final String? category;
  final SkillLevel? level;
  final SkillFormat? format;
  final SkillType? type;

  SkillsFiltered({
    required this.skills,
    this.category,
    this.level,
    this.format,
    this.type,
  });

  @override
  List<Object?> get props => [skills, category, level, format, type];
}

class SkillError extends SkillState {
  final String message;

  SkillError({required this.message});

  @override
  List<Object?> get props => [message];
}
