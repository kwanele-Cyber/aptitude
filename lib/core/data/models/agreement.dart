enum AgreementStatus { pending, accepted, rejected, completed, cancelled }

class Agreement {
  final String id;
  final String channelId;
  final String proposerId;
  final String receiverId;
  
  // Terms
  final String offerSkillId;
  final String requestSkillId;
  final int sessionsCount;
  final int minutesPerSession;
  final String frequency; // Weekly, Daily, etc.
  
  final AgreementStatus status;
  final int createdAt;
  final int? updatedAt;

  Agreement({
    required this.id,
    required this.channelId,
    required this.proposerId,
    required this.receiverId,
    required this.offerSkillId,
    required this.requestSkillId,
    required this.sessionsCount,
    required this.minutesPerSession,
    required this.frequency,
    this.status = AgreementStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'proposerId': proposerId,
      'receiverId': receiverId,
      'offerSkillId': offerSkillId,
      'requestSkillId': requestSkillId,
      'sessionsCount': sessionsCount,
      'minutesPerSession': minutesPerSession,
      'frequency': frequency,
      'status': status.index,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      proposerId: json['proposerId'] as String,
      receiverId: json['receiverId'] as String,
      offerSkillId: json['offerSkillId'] as String,
      requestSkillId: json['requestSkillId'] as String,
      sessionsCount: json['sessionsCount'] as int,
      minutesPerSession: json['minutesPerSession'] as int,
      frequency: json['frequency'] as String,
      status: AgreementStatus.values[json['status'] as int? ?? 0],
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
    );
  }
}
