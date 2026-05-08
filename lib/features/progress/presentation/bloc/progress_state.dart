import 'package:equatable/equatable.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';

abstract class ProgressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<SkillProgressEntity> progressList;

  ProgressLoaded({required this.progressList});

  @override
  List<Object?> get props => [progressList];
}

class ProgressTracked extends ProgressState {}

class GoalsLoaded extends ProgressState {
  final List<LearningGoalEntity> goals;

  GoalsLoaded({required this.goals});

  @override
  List<Object?> get props => [goals];
}

class GoalSet extends ProgressState {}

class GoalProgressUpdated extends ProgressState {}

class AchievementShared extends ProgressState {}

class ProgressError extends ProgressState {
  final String message;

  ProgressError({required this.message});

  @override
  List<Object?> get props => [message];
}
