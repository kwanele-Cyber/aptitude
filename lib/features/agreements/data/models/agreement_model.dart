import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';

class AgreementModel extends AgreementEntity {
  const AgreementModel({
    required super.id,
    required super.initiatorId,
    required super.initiatorName,
    required super.partnerId,
    required super.partnerName,
    required super.initiatorSkillId,
    required super.initiatorSkillTitle,
    required super.partnerSkillId,
    required super.partnerSkillTitle,
    super.status,
    required super.duration,
    required super.frequency,
    required super.sessionsCount,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.modifiedBy,
    super.cancelledBy,
    super.cancelledAt,
  });

  factory AgreementModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return AgreementModel(
      id: id,
      initiatorId: json['initiatorId'] as String? ?? '',
      initiatorName: json['initiatorName'] as String? ?? '',
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String? ?? '',
      initiatorSkillId: json['initiatorSkillId'] as String? ?? '',
      initiatorSkillTitle: json['initiatorSkillTitle'] as String? ?? '',
      partnerSkillId: json['partnerSkillId'] as String? ?? '',
      partnerSkillTitle: json['partnerSkillTitle'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      duration: json['duration'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      sessionsCount: json['sessionsCount'] as int? ?? 1,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      modifiedBy: json['modifiedBy'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initiatorId': initiatorId,
      'initiatorName': initiatorName,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'initiatorSkillId': initiatorSkillId,
      'initiatorSkillTitle': initiatorSkillTitle,
      'partnerSkillId': partnerSkillId,
      'partnerSkillTitle': partnerSkillTitle,
      'status': status.name,
      'duration': duration,
      'frequency': frequency,
      'sessionsCount': sessionsCount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'modifiedBy': modifiedBy,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  static AgreementStatus _parseStatus(String? status) {
    return AgreementStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AgreementStatus.pending,
    );
  }
}
