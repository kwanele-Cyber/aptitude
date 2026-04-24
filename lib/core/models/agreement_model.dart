enum AgreementStatus { pending, accepted, declined, completed, canceled }

class AgreementModel {
  final String id;
  final String learnerId;
  final String mentorId;
  final String learnerSkill;
  final String mentorSkill;
  final String frequency;
  final double duration;
  final String? parentId;
  final AgreementStatus status;
  final DateTime createdAt;

  AgreementModel({
    required this.id,
    required this.learnerId,
    required this.mentorId,
    required this.learnerSkill,
    required this.mentorSkill,
    required this.frequency,
    required this.duration,
    this.parentId,
    this.status = AgreementStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learnerId': learnerId,
      'mentorId': mentorId,
      'learnerSkill': learnerSkill,
      'mentorSkill': mentorSkill,
      'frequency': frequency,
      'duration': duration,
      'parentId': parentId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      id: json['id'] ?? '',
      learnerId: json['learnerId'] ?? '',
      mentorId: json['mentorId'] ?? '',
      learnerSkill: json['learnerSkill'] ?? '',
      mentorSkill: json['mentorSkill'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      parentId: json['parentId'],
      status: AgreementStatus.values.byName(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  AgreementModel copyWith({
    AgreementStatus? status,
  }) {
    return AgreementModel(
      id: id,
      learnerId: learnerId,
      mentorId: mentorId,
      learnerSkill: learnerSkill,
      mentorSkill: mentorSkill,
      frequency: frequency,
      duration: duration,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

