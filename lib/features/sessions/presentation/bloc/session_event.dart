import 'package:equatable/equatable.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

abstract class SessionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSessionRequested extends SessionEvent {
  final String matchId;
  final String skillId;
  final String skillTitle;
  final String initiatorId;
  final String participantId;
  final String participantName;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final SessionFormat format;
  final CancellationPolicy cancellationPolicy;
  final String? location;
  final String? meetingLink;
  final String? notes;
  final RecurrencePattern recurrencePattern;
  final int? maxParticipants;
  final bool remindersEnabled;

  CreateSessionRequested({
    required this.matchId,
    required this.skillId,
    required this.skillTitle,
    required this.initiatorId,
    required this.participantId,
    required this.participantName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.format,
    this.cancellationPolicy = CancellationPolicy.moderate,
    this.location,
    this.meetingLink,
    this.notes,
    this.recurrencePattern = RecurrencePattern.none,
    this.maxParticipants,
    this.remindersEnabled = true,
  });

  @override
  List<Object?> get props => [
        matchId,
        skillId,
        skillTitle,
        initiatorId,
        participantId,
        participantName,
        scheduledStart,
        scheduledEnd,
        format,
        cancellationPolicy,
        location,
        meetingLink,
        notes,
        recurrencePattern,
        maxParticipants,
        remindersEnabled,
      ];
}

class UpdateSessionRequested extends SessionEvent {
  final String id;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final SessionFormat? format;
  final String? location;
  final String? meetingLink;
  final String? notes;
  final int? maxParticipants;

  UpdateSessionRequested({
    required this.id,
    this.scheduledStart,
    this.scheduledEnd,
    this.format,
    this.location,
    this.meetingLink,
    this.notes,
    this.maxParticipants,
  });

  @override
  List<Object?> get props => [
        id,
        scheduledStart,
        scheduledEnd,
        format,
        location,
        meetingLink,
        notes,
        maxParticipants,
      ];
}

class CancelSessionRequested extends SessionEvent {
  final SessionEntity session;
  final String? reason;

  CancelSessionRequested({required this.session, this.reason});

  @override
  List<Object?> get props => [session, reason];
}

class GetSessionByIdRequested extends SessionEvent {
  final String id;

  GetSessionByIdRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class GetUserSessionsRequested extends SessionEvent {
  final String userId;
  final SessionStatus? status;

  GetUserSessionsRequested({required this.userId, this.status});

  @override
  List<Object?> get props => [userId, status];
}

class ConfirmSessionRequested extends SessionEvent {
  final String id;

  ConfirmSessionRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class JoinWaitlistRequested extends SessionEvent {
  final String sessionId;
  final String userId;

  JoinWaitlistRequested({required this.sessionId, required this.userId});

  @override
  List<Object?> get props => [sessionId, userId];
}

class LeaveWaitlistRequested extends SessionEvent {
  final String sessionId;
  final String userId;

  LeaveWaitlistRequested({required this.sessionId, required this.userId});

  @override
  List<Object?> get props => [sessionId, userId];
}

class ToggleSessionReminderRequested extends SessionEvent {
  final String id;
  final bool enabled;

  ToggleSessionReminderRequested({required this.id, required this.enabled});

  @override
  List<Object?> get props => [id, enabled];
}

class StartSessionRequested extends SessionEvent {
  final String id;

  StartSessionRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class CompleteSessionRequested extends SessionEvent {
  final String id;

  CompleteSessionRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class GenerateVerificationCodeRequested extends SessionEvent {
  final String sessionId;
  final String userId;

  GenerateVerificationCodeRequested({
    required this.sessionId,
    required this.userId,
  });

  @override
  List<Object?> get props => [sessionId, userId];
}

class VerifyAttendanceRequested extends SessionEvent {
  final String sessionId;
  final String userId;
  final String code;

  VerifyAttendanceRequested({
    required this.sessionId,
    required this.userId,
    required this.code,
  });

  @override
  List<Object?> get props => [sessionId, userId, code];
}
