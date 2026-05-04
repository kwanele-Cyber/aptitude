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

class SkillError extends SkillState {
  final String message;

  SkillError({required this.message});

  @override
  List<Object?> get props => [message];
}
