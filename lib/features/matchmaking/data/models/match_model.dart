import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.targetUserId,
    required super.targetSkillId,
    required super.matchedSkillId,
    required super.score,
    super.status,
    required super.createdAt,
    required super.targetUserName,
    required super.targetSkillTitle,
    required super.targetSkillCategory,
    required super.targetSkillLevel,
    required super.targetSkillFormat,
    super.targetTrustScore,
    super.targetIsVerified,
    super.distance,
    super.targetAvailability,
  });

  factory MatchModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return MatchModel(
      id: id,
      targetUserId: json['targetUserId'] as String? ?? '',
      targetSkillId: json['targetSkillId'] as String? ?? '',
      matchedSkillId: json['matchedSkillId'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      targetUserName: json['targetUserName'] as String? ?? '',
      targetSkillTitle: json['targetSkillTitle'] as String? ?? '',
      targetSkillCategory: json['targetSkillCategory'] as String? ?? '',
      targetSkillLevel: _parseLevel(json['targetSkillLevel'] as String?),
      targetSkillFormat: _parseFormat(json['targetSkillFormat'] as String?),
      targetTrustScore: (json['targetTrustScore'] as num?)?.toDouble() ?? 0,
      targetIsVerified: json['targetIsVerified'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble(),
      targetAvailability: (json['targetAvailability'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetUserId': targetUserId,
      'targetSkillId': targetSkillId,
      'matchedSkillId': matchedSkillId,
      'score': score,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'targetUserName': targetUserName,
      'targetSkillTitle': targetSkillTitle,
      'targetSkillCategory': targetSkillCategory,
      'targetSkillLevel': targetSkillLevel.name,
      'targetSkillFormat': targetSkillFormat.name,
      'targetTrustScore': targetTrustScore,
      'targetIsVerified': targetIsVerified,
      'distance': distance,
      'targetAvailability': targetAvailability,
    };
  }

  static MatchStatus _parseStatus(String? status) {
    return MatchStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => MatchStatus.pending,
    );
  }

  static SkillLevel _parseLevel(String? level) {
    return SkillLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => SkillLevel.beginner,
    );
  }

  static SkillFormat _parseFormat(String? format) {
    return SkillFormat.values.firstWhere(
      (e) => e.name == format,
      orElse: () => SkillFormat.online,
    );
  }
}
