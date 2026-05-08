import 'package:equatable/equatable.dart';

enum GoalStatus { active, completed, abandoned }

class LearningGoalEntity extends Equatable {
  final String id;
  final String userId;
  final String skillId;
  final String skillTitle;
  final String description;
  final int targetLevel;
  final DateTime? targetDate;
  final int progressPercent;
  final GoalStatus status;
  final DateTime createdAt;

  const LearningGoalEntity({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.skillTitle,
    required this.description,
    this.targetLevel = 1,
    this.targetDate,
    this.progressPercent = 0,
    this.status = GoalStatus.active,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        skillId,
        skillTitle,
        description,
        targetLevel,
        targetDate,
        progressPercent,
        status,
        createdAt,
      ];
}
