import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/sessions/domain/usecases/cancel_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/confirm_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/create_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_by_id_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/join_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/leave_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/toggle_session_reminder_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/complete_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/generate_verification_code_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/start_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/verify_attendance_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final CreateSessionUseCase createSessionUseCase;
  final UpdateSessionUseCase updateSessionUseCase;
  final CancelSessionUseCase cancelSessionUseCase;
  final GetSessionByIdUseCase getSessionByIdUseCase;
  final GetUserSessionsUseCase getUserSessionsUseCase;
  final ConfirmSessionUseCase confirmSessionUseCase;
  final JoinWaitlistUseCase joinWaitlistUseCase;
  final LeaveWaitlistUseCase leaveWaitlistUseCase;
  final ToggleSessionReminderUseCase toggleSessionReminderUseCase;
  final StartSessionUseCase startSessionUseCase;
  final CompleteSessionUseCase completeSessionUseCase;
  final GenerateVerificationCodeUseCase generateVerificationCodeUseCase;
  final VerifyAttendanceUseCase verifyAttendanceUseCase;

  SessionBloc({
    required this.createSessionUseCase,
    required this.updateSessionUseCase,
    required this.cancelSessionUseCase,
    required this.getSessionByIdUseCase,
    required this.getUserSessionsUseCase,
    required this.confirmSessionUseCase,
    required this.joinWaitlistUseCase,
    required this.leaveWaitlistUseCase,
    required this.toggleSessionReminderUseCase,
    required this.startSessionUseCase,
    required this.completeSessionUseCase,
    required this.generateVerificationCodeUseCase,
    required this.verifyAttendanceUseCase,
  }) : super(SessionInitial()) {
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<UpdateSessionRequested>(_onUpdateSessionRequested);
    on<CancelSessionRequested>(_onCancelSessionRequested);
    on<GetSessionByIdRequested>(_onGetSessionByIdRequested);
    on<GetUserSessionsRequested>(_onGetUserSessionsRequested);
    on<ConfirmSessionRequested>(_onConfirmSessionRequested);
    on<JoinWaitlistRequested>(_onJoinWaitlistRequested);
    on<LeaveWaitlistRequested>(_onLeaveWaitlistRequested);
    on<ToggleSessionReminderRequested>(_onToggleSessionReminderRequested);
    on<StartSessionRequested>(_onStartSessionRequested);
    on<CompleteSessionRequested>(_onCompleteSessionRequested);
    on<GenerateVerificationCodeRequested>(_onGenerateVerificationCodeRequested);
    on<VerifyAttendanceRequested>(_onVerifyAttendanceRequested);
  }

  Future _onCreateSessionRequested(
    CreateSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    final result = await createSessionUseCase(
      CreateSessionParams(
        matchId: event.matchId,
        skillId: event.skillId,
        skillTitle: event.skillTitle,
        initiatorId: event.initiatorId,
        participantId: event.participantId,
        participantName: event.participantName,
        scheduledStart: event.scheduledStart,
        scheduledEnd: event.scheduledEnd,
        format: event.format,
        cancellationPolicy: event.cancellationPolicy,
        location: event.location,
        meetingLink: event.meetingLink,
        notes: event.notes,
        recurrencePattern: event.recurrencePattern,
        maxParticipants: event.maxParticipants,
        remindersEnabled: event.remindersEnabled,
      ),
    );

    await result.fold(
      (left) async => emit(SessionError(message: 'Failed to create session')),
      (right) async => emit(SessionCreated(session: right)),
    );
  }

  Future _onUpdateSessionRequested(
    UpdateSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    final result = await updateSessionUseCase(
      UpdateSessionParams(
        id: event.id,
        scheduledStart: event.scheduledStart,
        scheduledEnd: event.scheduledEnd,
        format: event.format,
        location: event.location,
        meetingLink: event.meetingLink,
        notes: event.notes,
        maxParticipants: event.maxParticipants,
      ),
    );

    await result.fold(
      (left) async => emit(SessionError(message: 'Failed to update session')),
      (right) async => emit(SessionUpdated(session: right)),
    );
  }

  Future _onCancelSessionRequested(
    CancelSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await cancelSessionUseCase(
      CancelSessionParams(session: event.session, reason: event.reason),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: left.message ?? 'Failed to cancel session')),
      (right) async => emit(SessionCancelled(session: right)),
    );
  }

  Future _onGetSessionByIdRequested(
    GetSessionByIdRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    final result = await getSessionByIdUseCase(
      GetSessionByIdParams(id: event.id),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to load session details')),
      (right) async => emit(SessionLoaded(session: right)),
    );
  }

  Future _onGetUserSessionsRequested(
    GetUserSessionsRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    final result = await getUserSessionsUseCase(
      GetUserSessionsParams(userId: event.userId, status: event.status),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to load sessions')),
      (right) async => emit(UserSessionsLoaded(sessions: right)),
    );
  }

  Future _onConfirmSessionRequested(
    ConfirmSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await confirmSessionUseCase(
      ConfirmSessionParams(id: event.id),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to confirm session')),
      (right) async => emit(SessionConfirmed(session: right)),
    );
  }

  Future _onJoinWaitlistRequested(
    JoinWaitlistRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await joinWaitlistUseCase(
      JoinWaitlistParams(
        sessionId: event.sessionId,
        userId: event.userId,
      ),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to join waitlist')),
      (right) async => emit(WaitlistUpdated(session: right)),
    );
  }

  Future _onLeaveWaitlistRequested(
    LeaveWaitlistRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await leaveWaitlistUseCase(
      LeaveWaitlistParams(
        sessionId: event.sessionId,
        userId: event.userId,
      ),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to leave waitlist')),
      (right) async => emit(WaitlistUpdated(session: right)),
    );
  }

  Future _onToggleSessionReminderRequested(
    ToggleSessionReminderRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await toggleSessionReminderUseCase(
      ToggleSessionReminderParams(id: event.id, enabled: event.enabled),
    );

    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to update reminder setting')),
      (right) async => emit(SessionReminderToggled(session: right)),
    );
  }

  Future<void> _onStartSessionRequested(
    StartSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await startSessionUseCase(
      StartSessionParams(id: event.id),
    );
    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to start session')),
      (right) async => emit(SessionStarted(session: right)),
    );
  }

  Future<void> _onCompleteSessionRequested(
    CompleteSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await completeSessionUseCase(
      CompleteSessionParams(id: event.id),
    );
    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to complete session')),
      (right) async => emit(SessionCompleted(session: right)),
    );
  }

  Future<void> _onGenerateVerificationCodeRequested(
    GenerateVerificationCodeRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await generateVerificationCodeUseCase(
      GenerateVerificationCodeParams(
        sessionId: event.sessionId,
        userId: event.userId,
      ),
    );
    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to generate verification code')),
      (right) async => emit(SessionUpdated(session: right)),
    );
  }

  Future<void> _onVerifyAttendanceRequested(
    VerifyAttendanceRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionActionLoading());
    final result = await verifyAttendanceUseCase(
      VerifyAttendanceParams(
        sessionId: event.sessionId,
        userId: event.userId,
        code: event.code,
      ),
    );
    await result.fold(
      (left) async =>
          emit(SessionError(message: 'Failed to verify attendance')),
      (right) async => emit(SessionUpdated(session: right)),
    );
  }
}
