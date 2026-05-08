import 'package:myapp/lib/features/agreement/domain/entity/agreement_entity.dart';

class AgreementModel extends AgreementEntity {
  const AgreementModel({
    required super.id,
    required super.initiatorId,
    required super.partnerId,
    required super.skillId,
    required super.skillName,
    required super.initiatorRole,
    required super.partnerRole,
    required super.durationWeeks,
    required super.sessionsPerWeek,
    super.preferredDays,
    required super.format,
    required super.location,
    super.materialsNeeded,
    super.notes,
    super.status,
    required super.createdAt,
    super.updatedAt,
    super.completedAt,
    super.cancelledAt,
    super.cancellationReason,
    super.modificationNotes,
  });

  factory AgreementModel.fromJson(String id, Map<String, dynamic> json) {
    return AgreementModel(
      id: id,
      initiatorId: json['initiatorId'] as String? ?? '',
      partnerId: json['partnerId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      skillName: json['skillName'] as String? ?? '',
      initiatorRole: _parseRole(json['initiatorRole'] as String?),
      partnerRole: _parseRole(json['partnerRole'] as String?),
      durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 4,
      sessionsPerWeek: (json['sessionsPerWeek'] as num?)?.toInt() ?? 1,
      preferredDays: (json['preferredDays'] as List?)?.map((e) => e.toString()).toList() ?? [],
      format: _parseFormat(json['format'] as String?),
      location: json['location'] as String? ?? '',
      materialsNeeded: json['materialsNeeded'] as String?,
      notes: json['notes'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt'] as String) : null,
      cancellationReason: json['cancellationReason'] as String?,
      modificationNotes: json['modificationNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initiatorId': initiatorId,
      'partnerId': partnerId,
      'skillId': skillId,
      'skillName': skillName,
      'initiatorRole': initiatorRole.name,
      'partnerRole': partnerRole.name,
      'durationWeeks': durationWeeks,
      'sessionsPerWeek': sessionsPerWeek,
      'preferredDays': preferredDays,
      'format': format.name,
      'location': location,
      if (materialsNeeded != null) 'materialsNeeded': materialsNeeded,
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (modificationNotes != null) 'modificationNotes': modificationNotes,
    };
  }

  static AgreementRole _parseRole(String? role) {
    switch (role) {
      case 'teacher': return AgreementRole.teacher;
      default: return AgreementRole.learner;
    }
  }

  static AgreementFormat _parseFormat(String? format) {
    switch (format) {
      case 'inPerson': return AgreementFormat.inPerson;
      case 'hybrid': return AgreementFormat.hybrid;
      default: return AgreementFormat.online;
    }
  }

  static AgreementStatus _parseStatus(String? status) {
    switch (status) {
      case 'draft': return AgreementStatus.draft;
      case 'pending': return AgreementStatus.pending;
      case 'active': return AgreementStatus.active;
      case 'modified': return AgreementStatus.modified;
      case 'completed': return AgreementStatus.completed;
      case 'cancelled': return AgreementStatus.cancelled;
      case 'declined': return AgreementStatus.declined;
      default: return AgreementStatus.draft;
    }
  }
}
