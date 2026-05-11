import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';

class LearningGoalModel extends LearningGoalEntity {
  const LearningGoalModel({
    required super.id,
    required super.userId,
    required super.skillId,
    required super.skillTitle,
    required super.description,
    super.targetLevel,
    super.targetDate,
    super.progressPercent,
    super.status,
    required super.createdAt,
  });

  factory LearningGoalModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return LearningGoalModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      skillTitle: json['skillTitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetLevel: (json['targetLevel'] as num?)?.toInt() ?? 1,
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'] as String)
          : null,
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'skillId': skillId,
      'skillTitle': skillTitle,
      'description': description,
      'targetLevel': targetLevel,
      'targetDate': targetDate?.toIso8601String(),
      'progressPercent': progressPercent,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static GoalStatus _parseStatus(String? status) {
    return GoalStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => GoalStatus.active,
    );
  }
}
