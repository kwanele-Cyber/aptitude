import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';

class SkillProgressModel extends SkillProgressEntity {
  const SkillProgressModel({
    required super.id,
    required super.userId,
    required super.skillId,
    required super.skillTitle,
    super.xpPoints,
    super.hoursLogged,
    super.sessionsCompleted,
    super.currentStreak,
    super.lastPracticedAt,
    super.milestones,
    required super.updatedAt,
  });

  factory SkillProgressModel.fromJson(String key, Map<String, dynamic> json) {
    return SkillProgressModel(
      id: key,
      userId: json['userId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      skillTitle: json['skillTitle'] as String? ?? '',
      xpPoints: (json['xpPoints'] as num?)?.toInt() ?? 0,
      hoursLogged: (json['hoursLogged'] as num?)?.toDouble() ?? 0,
      sessionsCompleted: (json['sessionsCompleted'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      lastPracticedAt: json['lastPracticedAt'] != null
          ? DateTime.tryParse(json['lastPracticedAt'] as String)
          : null,
      milestones: (json['milestones'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'skillId': skillId,
      'skillTitle': skillTitle,
      'xpPoints': xpPoints,
      'hoursLogged': hoursLogged,
      'sessionsCompleted': sessionsCompleted,
      'currentStreak': currentStreak,
      'lastPracticedAt': lastPracticedAt?.toIso8601String(),
      'milestones': milestones,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
