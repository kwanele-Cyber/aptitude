import 'package:equatable/equatable.dart';

enum SessionStatus { scheduled, confirmed, inProgress, completed, cancelled, noShow }

enum SessionFormat { online, inPerson }

enum CancellationPolicy { flexible, moderate, strict }

enum RecurrencePattern { none, daily, weekly, biweekly, monthly }

class SessionEntity extends Equatable {
  final String id;
  final String matchId;
  final String skillId;
  final String skillTitle;
  final String initiatorId;
  final String participantId;
  final String participantName;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final SessionFormat format;
  final SessionStatus status;
  final CancellationPolicy cancellationPolicy;
  final String? location;
  final String? meetingLink;
  final String? notes;
  final RecurrencePattern recurrencePattern;
  final int? maxParticipants;
  final List<String> waitlistUserIds;
  final bool remindersEnabled;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? verificationCode;
  final bool initiatorVerified;
  final bool participantVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionEntity({
    required this.id,
    required this.matchId,
    required this.skillId,
    required this.skillTitle,
    required this.initiatorId,
    required this.participantId,
    required this.participantName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.format,
    this.status = SessionStatus.scheduled,
    this.cancellationPolicy = CancellationPolicy.moderate,
    this.location,
    this.meetingLink,
    this.notes,
    this.recurrencePattern = RecurrencePattern.none,
    this.maxParticipants,
    this.waitlistUserIds = const [],
    this.remindersEnabled = true,
    this.cancelledAt,
    this.cancelReason,
    this.confirmedAt,
    this.startedAt,
    this.completedAt,
    this.verificationCode,
    this.initiatorVerified = false,
    this.participantVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration get duration => scheduledEnd.difference(scheduledStart);

  bool get isPast => scheduledEnd.isBefore(DateTime.now());

  bool get isUpcoming => scheduledStart.isAfter(DateTime.now());

  bool get isFull =>
      maxParticipants != null && maxParticipants! > 0 &&
      // Count: initiator + participant = 2 base participants
      // For group sessions, maxParticipants would be higher
      waitlistUserIds.length >= maxParticipants!;

  bool canCancel(DateTime now) {
    if (status == SessionStatus.cancelled || status == SessionStatus.completed) {
      return false;
    }
    switch (cancellationPolicy) {
      case CancellationPolicy.flexible:
        return true;
      case CancellationPolicy.moderate:
        return scheduledStart.difference(now).inHours >= 24;
      case CancellationPolicy.strict:
        return scheduledStart.difference(now).inHours >= 48;
    }
  }

  String? cancellationRestrictionMessage(DateTime now) {
    if (status == SessionStatus.cancelled || status == SessionStatus.completed) {
      return 'Session is already ${status.name}.';
    }
    switch (cancellationPolicy) {
      case CancellationPolicy.flexible:
        return null;
      case CancellationPolicy.moderate:
        if (scheduledStart.difference(now).inHours < 24) {
          return 'Cancellation requires at least 24 hours notice under the moderate policy.';
        }
        return null;
      case CancellationPolicy.strict:
        if (scheduledStart.difference(now).inHours < 48) {
          return 'Cancellation requires at least 48 hours notice under the strict policy.';
        }
        return null;
    }
  }

  SessionEntity copyWith({
    String? id,
    String? matchId,
    String? skillId,
    String? skillTitle,
    String? initiatorId,
    String? participantId,
    String? participantName,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    SessionFormat? format,
    SessionStatus? status,
    CancellationPolicy? cancellationPolicy,
    String? location,
    String? meetingLink,
    String? notes,
    RecurrencePattern? recurrencePattern,
    int? maxParticipants,
    List<String>? waitlistUserIds,
    bool? remindersEnabled,
    DateTime? cancelledAt,
    String? cancelReason,
    DateTime? confirmedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? verificationCode,
    bool? initiatorVerified,
    bool? participantVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      skillId: skillId ?? this.skillId,
      skillTitle: skillTitle ?? this.skillTitle,
      initiatorId: initiatorId ?? this.initiatorId,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      format: format ?? this.format,
      status: status ?? this.status,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      notes: notes ?? this.notes,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      waitlistUserIds: waitlistUserIds ?? this.waitlistUserIds,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      verificationCode: verificationCode ?? this.verificationCode,
      initiatorVerified: initiatorVerified ?? this.initiatorVerified,
      participantVerified: participantVerified ?? this.participantVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        matchId,
        skillId,
        skillTitle,
        initiatorId,
        participantId,
        participantName,
        scheduledStart,
        scheduledEnd,
        format,
        status,
        cancellationPolicy,
        location,
        meetingLink,
        notes,
        recurrencePattern,
        maxParticipants,
        waitlistUserIds,
        remindersEnabled,
        cancelledAt,
        cancelReason,
        confirmedAt,
        startedAt,
        completedAt,
        verificationCode,
        initiatorVerified,
        participantVerified,
        createdAt,
        updatedAt,
      ];
}
