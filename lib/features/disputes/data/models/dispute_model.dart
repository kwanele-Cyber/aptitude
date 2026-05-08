import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';

class DisputeModel extends DisputeEntity {
  const DisputeModel({
    required super.id,
    required super.type,
    required super.reporterId,
    required super.reporterName,
    super.reportedUserId,
    super.reportedUserName,
    super.respondentId,
    super.agreementId,
    super.sessionId,
    required super.reason,
    required super.description,
    super.evidenceUrls = const [],
    super.status = DisputeStatus.pending,
    super.resolution,
    super.resolvedBy,
    super.resolvedAt,
    super.appealReason,
    super.appealDecision,
    super.appealedAt,
    super.appealDecisionAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DisputeModel.fromJson(String key, Map<String, dynamic> json) {
    return DisputeModel(
      id: key,
      type: _parseDisputeType(json['type']),
      reporterId: json['reporterId'] as String? ?? '',
      reporterName: json['reporterName'] as String? ?? '',
      reportedUserId: json['reportedUserId'] as String?,
      reportedUserName: json['reportedUserName'] as String?,
      respondentId: json['respondentId'] as String?,
      agreementId: json['agreementId'] as String?,
      sessionId: json['sessionId'] as String?,
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String? ?? '',
      evidenceUrls: _parseStringList(json['evidenceUrls']),
      status: _parseDisputeStatus(json['status']),
      resolution: json['resolution'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
      appealReason: json['appealReason'] as String?,
      appealDecision: json['appealDecision'] as String?,
      appealedAt: json['appealedAt'] != null
          ? DateTime.tryParse(json['appealedAt'] as String)
          : null,
      appealDecisionAt: json['appealDecisionAt'] != null
          ? DateTime.tryParse(json['appealDecisionAt'] as String)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'respondentId': respondentId,
      'agreementId': agreementId,
      'sessionId': sessionId,
      'reason': reason,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'status': status.name,
      'resolution': resolution,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'appealReason': appealReason,
      'appealDecision': appealDecision,
      'appealedAt': appealedAt?.toIso8601String(),
      'appealDecisionAt': appealDecisionAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DisputeType _parseDisputeType(dynamic value) {
    if (value is String) {
      return DisputeType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DisputeType.report,
      );
    }
    return DisputeType.report;
  }

  static DisputeStatus _parseDisputeStatus(dynamic value) {
    if (value is String) {
      return DisputeStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DisputeStatus.pending,
      );
    }
    return DisputeStatus.pending;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
