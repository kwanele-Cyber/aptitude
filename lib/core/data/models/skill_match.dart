enum MatchStatus { pending, accepted, declined }

class SkillMatch {
  final String mid;
  final String offeringUserId;
  final String requestingUserId;
  final String skillId;
  final DateTime createdAt;
  final MatchStatus status;

  SkillMatch({
    required this.mid,
    required this.offeringUserId,
    required this.requestingUserId,
    required this.skillId,
    required this.createdAt,
    required this.status,
  });
}
