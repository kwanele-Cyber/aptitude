import 'package:equatable/equatable.dart';

enum DisputeType { report, dispute }

enum DisputeStatus { pending, underReview, resolved, dismissed, appealed }

class DisputeEntity extends Equatable {
  final String id;
  final DisputeType type;
  final String reporterId;
  final String reporterName;
  final String? reportedUserId;
  final String? reportedUserName;
  final String? respondentId;
  final String? agreementId;
  final String? sessionId;
  final String reason;
  final String description;
  final List<String> evidenceUrls;
  final DisputeStatus status;
  final String? resolution;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? appealReason;
  final String? appealDecision;
  final DateTime? appealedAt;
  final DateTime? appealDecisionAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DisputeEntity({
    required this.id,
    required this.type,
    required this.reporterId,
    required this.reporterName,
    this.reportedUserId,
    this.reportedUserName,
    this.respondentId,
    this.agreementId,
    this.sessionId,
    required this.reason,
    required this.description,
    this.evidenceUrls = const [],
    this.status = DisputeStatus.pending,
    this.resolution,
    this.resolvedBy,
    this.resolvedAt,
    this.appealReason,
    this.appealDecision,
    this.appealedAt,
    this.appealDecisionAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canAppeal =>
      status == DisputeStatus.resolved && appealReason == null;

  @override
  List<Object?> get props => [
        id,
        type,
        reporterId,
        reporterName,
        reportedUserId,
        reportedUserName,
        respondentId,
        agreementId,
        sessionId,
        reason,
        description,
        evidenceUrls,
        status,
        resolution,
        resolvedBy,
        resolvedAt,
        appealReason,
        appealDecision,
        appealedAt,
        appealDecisionAt,
        createdAt,
        updatedAt,
      ];
}
