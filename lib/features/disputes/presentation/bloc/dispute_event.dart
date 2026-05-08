import 'package:equatable/equatable.dart';

abstract class DisputeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportUserRequested extends DisputeEvent {
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String reason;
  final String description;
  final List<String> evidenceUrls;

  ReportUserRequested({
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    required this.description,
    this.evidenceUrls = const [],
  });

  @override
  List<Object?> get props => [
        reporterId,
        reporterName,
        reportedUserId,
        reportedUserName,
        reason,
        description,
        evidenceUrls,
      ];
}

class CreateDisputeRequested extends DisputeEvent {
  final String reporterId;
  final String reporterName;
  final String respondentId;
  final String reason;
  final String description;
  final String? agreementId;
  final String? sessionId;
  final List<String> evidenceUrls;

  CreateDisputeRequested({
    required this.reporterId,
    required this.reporterName,
    required this.respondentId,
    required this.reason,
    required this.description,
    this.agreementId,
    this.sessionId,
    this.evidenceUrls = const [],
  });

  @override
  List<Object?> get props => [
        reporterId,
        reporterName,
        respondentId,
        reason,
        description,
        agreementId,
        sessionId,
        evidenceUrls,
      ];
}

class ResolveDisputeRequested extends DisputeEvent {
  final String disputeId;
  final String resolution;
  final String resolvedBy;
  final String newStatus;

  ResolveDisputeRequested({
    required this.disputeId,
    required this.resolution,
    required this.resolvedBy,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [disputeId, resolution, resolvedBy, newStatus];
}

class AppealDecisionRequested extends DisputeEvent {
  final String disputeId;
  final String appealReason;

  AppealDecisionRequested({
    required this.disputeId,
    required this.appealReason,
  });

  @override
  List<Object?> get props => [disputeId, appealReason];
}

class FetchDisputesRequested extends DisputeEvent {
  final String userId;

  FetchDisputesRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FetchAllDisputesRequested extends DisputeEvent {}

class FetchDisputeByIdRequested extends DisputeEvent {
  final String disputeId;

  FetchDisputeByIdRequested({required this.disputeId});

  @override
  List<Object?> get props => [disputeId];
}
