import 'package:equatable/equatable.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

enum MatchStatus { pending, accepted, rejected, ignored }

class MatchEntity extends Equatable {
  final String id;
  final String targetUserId;
  final String targetSkillId;
  final String matchedSkillId;
  final double score;
  final MatchStatus status;
  final DateTime createdAt;
  final String targetUserName;
  final String targetSkillTitle;
  final String targetSkillCategory;
  final SkillLevel targetSkillLevel;
  final SkillFormat targetSkillFormat;
  final double targetTrustScore;
  final bool targetIsVerified;
  final double? distance;
  final List<String> targetAvailability;

  const MatchEntity({
    required this.id,
    required this.targetUserId,
    required this.targetSkillId,
    required this.matchedSkillId,
    required this.score,
    this.status = MatchStatus.pending,
    required this.createdAt,
    required this.targetUserName,
    required this.targetSkillTitle,
    required this.targetSkillCategory,
    required this.targetSkillLevel,
    required this.targetSkillFormat,
    this.targetTrustScore = 0,
    this.targetIsVerified = false,
    this.distance,
    this.targetAvailability = const [],
  });

  @override
  List<Object?> get props => [
        id,
        targetUserId,
        targetSkillId,
        matchedSkillId,
        score,
        status,
        createdAt,
        targetUserName,
        targetSkillTitle,
        targetSkillCategory,
        targetSkillLevel,
        targetSkillFormat,
        targetTrustScore,
        targetIsVerified,
        distance,
        targetAvailability,
      ];
}
