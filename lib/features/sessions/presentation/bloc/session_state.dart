import 'package:equatable/equatable.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

abstract class SessionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionCreated extends SessionState {
  final SessionEntity session;

  SessionCreated({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionUpdated extends SessionState {
  final SessionEntity session;

  SessionUpdated({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionCancelled extends SessionState {
  final SessionEntity session;

  SessionCancelled({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionLoaded extends SessionState {
  final SessionEntity session;

  SessionLoaded({required this.session});

  @override
  List<Object?> get props => [session];
}

class UserSessionsLoaded extends SessionState {
  final List<SessionEntity> sessions;

  UserSessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class SessionConfirmed extends SessionState {
  final SessionEntity session;

  SessionConfirmed({required this.session});

  @override
  List<Object?> get props => [session];
}

class WaitlistUpdated extends SessionState {
  final SessionEntity session;

  WaitlistUpdated({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionReminderToggled extends SessionState {
  final SessionEntity session;

  SessionReminderToggled({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionStarted extends SessionState {
  final SessionEntity session;

  SessionStarted({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionCompleted extends SessionState {
  final SessionEntity session;

  SessionCompleted({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionActionLoading extends SessionState {}

class SessionError extends SessionState {
  final String message;

  SessionError({required this.message});

  @override
  List<Object?> get props => [message];
}
