import 'package:equatable/equatable.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';

abstract class ProgressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProgressRequested extends ProgressEvent {
  final String userId;

  FetchProgressRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class TrackProgressRequested extends ProgressEvent {
  final String userId;
  final String skillId;
  final String skillTitle;
  final double hoursLogged;
  final int sessionsCompleted;
  final int xpGained;

  TrackProgressRequested({
    required this.userId,
    required this.skillId,
    required this.skillTitle,
    this.hoursLogged = 0,
    this.sessionsCompleted = 0,
    this.xpGained = 0,
  });

  @override
  List<Object?> get props =>
      [userId, skillId, skillTitle, hoursLogged, sessionsCompleted, xpGained];
}

class FetchGoalsRequested extends ProgressEvent {
  final String userId;

  FetchGoalsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SetGoalRequested extends ProgressEvent {
  final LearningGoalEntity goal;

  SetGoalRequested({required this.goal});

  @override
  List<Object?> get props => [goal];
}

class UpdateGoalProgressRequested extends ProgressEvent {
  final String goalId;
  final int progressPercent;

  UpdateGoalProgressRequested({
    required this.goalId,
    required this.progressPercent,
  });

  @override
  List<Object?> get props => [goalId, progressPercent];
}

class ShareAchievementRequested extends ProgressEvent {
  final String progressId;
  final String milestone;

  ShareAchievementRequested({
    required this.progressId,
    required this.milestone,
  });

  @override
  List<Object?> get props => [progressId, milestone];
}
