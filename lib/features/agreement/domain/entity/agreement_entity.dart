import 'package:equatable/equatable.dart';

enum AgreementStatus {
  draft,      // Being created, not yet sent
  pending,    // Sent, awaiting response
  active,     // Accepted, ready for sessions
  modified,   // Counter-proposal received
  completed,  // All sessions finished
  cancelled,  // Cancelled by either party
  declined,   // Explicitly rejected
}

enum AgreementRole {
  teacher,
  learner,
}

enum AgreementFormat {
  online,
  inPerson,
  hybrid,
}

class AgreementEntity extends Equatable {
  final String id;
  final String initiatorId;
  final String partnerId;
  final String skillId;
  final String skillName;          // Denormalized for display
  final AgreementRole initiatorRole;
  final AgreementRole partnerRole;
  final int durationWeeks;
  final int sessionsPerWeek;
  final List<String> preferredDays;  // ['monday', 'wednesday', etc.]
  final AgreementFormat format;
  final String location;              // Address or meeting link
  final String? materialsNeeded;
  final String notes;
  final AgreementStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? modificationNotes;    // Notes from modification request

  const AgreementEntity({
    required this.id,
    required this.initiatorId,
    required this.partnerId,
    required this.skillId,
    required this.skillName,
    required this.initiatorRole,
    required this.partnerRole,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    this.preferredDays = const [],
    required this.format,
    required this.location,
    this.materialsNeeded,
    this.notes = '',
    this.status = AgreementStatus.draft,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.modificationNotes,
  });

  bool get isActive => status == AgreementStatus.active;
  bool get isPending => status == AgreementStatus.pending;
  bool get isCompleted => status == AgreementStatus.completed;
  bool get isCancelled => status == AgreementStatus.cancelled || status == AgreementStatus.declined;
  bool get isModifiable => status == AgreementStatus.pending || status == AgreementStatus.active;

  String get totalSessions => '${durationWeeks * sessionsPerWeek} sessions';
  String get durationDisplay => '$durationWeeks week${durationWeeks != 1 ? 's' : ''}';
  String get frequencyDisplay => '$sessionsPerWeek session${sessionsPerWeek != 1 ? 's' : ''}/week';

  @override
  List<Object?> get props => [
    id, initiatorId, partnerId, skillId, skillName,
    initiatorRole, partnerRole, durationWeeks, sessionsPerWeek,
    preferredDays, format, location, materialsNeeded, notes,
    status, createdAt, updatedAt, completedAt, cancelledAt,
    cancellationReason, modificationNotes,
  ];
}