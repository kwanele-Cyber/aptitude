import 'package:uuid/uuid.dart';

enum MatchStatus { pending, accepted, declined }

class SkillMatch {
  final String mid;
  final String offeringUserId;
  final String requestingUserId;
  final String skillId;
  final DateTime createdAt;
  final MatchStatus status;

  SkillMatch({
    String? mid,
    required this.offeringUserId,
    required this.requestingUserId,
    required this.skillId,
    required this.createdAt,
    required this.status,
  }) : mid = mid ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'mid': mid,
      'offeringUserId': offeringUserId,
      'requestingUserId': requestingUserId,
      'skillId': skillId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.name,
    };
  }

  factory SkillMatch.fromJson(Map<String, dynamic> json) {
    return SkillMatch(
      mid: json['mid'],
      offeringUserId: json['offeringUserId'],
      requestingUserId: json['requestingUserId'],
      skillId: json['skillId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      status: MatchStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}
