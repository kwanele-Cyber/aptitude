import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/usecases/cancel_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/confirm_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/create_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_by_id_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/join_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/leave_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/toggle_session_reminder_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/start_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/complete_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/generate_verification_code_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/verify_attendance_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCreateSessionUseCase extends Mock implements CreateSessionUseCase {}
class MockUpdateSessionUseCase extends Mock implements UpdateSessionUseCase {}
class MockCancelSessionUseCase extends Mock implements CancelSessionUseCase {}
class MockGetSessionByIdUseCase extends Mock implements GetSessionByIdUseCase {}
class MockGetUserSessionsUseCase extends Mock implements GetUserSessionsUseCase {}
class MockConfirmSessionUseCase extends Mock implements ConfirmSessionUseCase {}
class MockJoinWaitlistUseCase extends Mock implements JoinWaitlistUseCase {}
class MockLeaveWaitlistUseCase extends Mock implements LeaveWaitlistUseCase {}
class MockToggleSessionReminderUseCase extends Mock
    implements ToggleSessionReminderUseCase {}
class MockStartSessionUseCase extends Mock implements StartSessionUseCase {}
class MockCompleteSessionUseCase extends Mock
    implements CompleteSessionUseCase {}
class MockGenerateVerificationCodeUseCase extends Mock
    implements GenerateVerificationCodeUseCase {}
class MockVerifyAttendanceUseCase extends Mock
    implements VerifyAttendanceUseCase {}

final tSession = SessionEntity(
  id: 'session1',
  matchId: 'match1',
  skillId: 'skill1',
  skillTitle: 'Flutter Development',
  initiatorId: 'user1',
  participantId: 'user2',
  participantName: 'User Two',
  scheduledStart: DateTime(2025, 2, 1, 10, 0),
  scheduledEnd: DateTime(2025, 2, 1, 11, 0),
  format: SessionFormat.online,
  status: SessionStatus.scheduled,
  cancellationPolicy: CancellationPolicy.moderate,
  meetingLink: 'https://zoom.us/j/123',
  createdAt: DateTime(2025, 1, 28),
  updatedAt: DateTime(2025, 1, 28),
);

void main() {
  late SessionBloc bloc;
  late MockCreateSessionUseCase mockCreateUseCase;
  late MockUpdateSessionUseCase mockUpdateUseCase;
  late MockCancelSessionUseCase mockCancelUseCase;
  late MockGetSessionByIdUseCase mockGetByIdUseCase;
  late MockGetUserSessionsUseCase mockGetUserSessionsUseCase;
  late MockConfirmSessionUseCase mockConfirmUseCase;
  late MockJoinWaitlistUseCase mockJoinWaitlistUseCase;
  late MockLeaveWaitlistUseCase mockLeaveWaitlistUseCase;
  late MockToggleSessionReminderUseCase mockToggleReminderUseCase;
  late MockStartSessionUseCase mockStartSessionUseCase;
  late MockCompleteSessionUseCase mockCompleteSessionUseCase;
  late MockGenerateVerificationCodeUseCase mockGenerateCodeUseCase;
  late MockVerifyAttendanceUseCase mockVerifyAttendanceUseCase;

  setUpAll(() {
    registerFallbackValue(CreateSessionParams(
      matchId: '',
      skillId: '',
      skillTitle: '',
      initiatorId: '',
      participantId: '',
      participantName: '',
      scheduledStart: DateTime(2025, 1, 1),
      scheduledEnd: DateTime(2025, 1, 1),
      format: SessionFormat.online,
    ));
    registerFallbackValue(UpdateSessionParams(id: ''));
    registerFallbackValue(CancelSessionParams(session: tSession));
    registerFallbackValue(GetSessionByIdParams(id: ''));
    registerFallbackValue(GetUserSessionsParams(userId: ''));
    registerFallbackValue(ConfirmSessionParams(id: ''));
    registerFallbackValue(JoinWaitlistParams(sessionId: '', userId: ''));
    registerFallbackValue(LeaveWaitlistParams(sessionId: '', userId: ''));
    registerFallbackValue(ToggleSessionReminderParams(id: '', enabled: false));
    registerFallbackValue(StartSessionParams(id: ''));
    registerFallbackValue(CompleteSessionParams(id: ''));
    registerFallbackValue(
        GenerateVerificationCodeParams(sessionId: '', userId: ''));
    registerFallbackValue(
        VerifyAttendanceParams(sessionId: '', userId: '', code: ''));
  });

  setUp(() {
    mockCreateUseCase = MockCreateSessionUseCase();
    mockUpdateUseCase = MockUpdateSessionUseCase();
    mockCancelUseCase = MockCancelSessionUseCase();
    mockGetByIdUseCase = MockGetSessionByIdUseCase();
    mockGetUserSessionsUseCase = MockGetUserSessionsUseCase();
    mockConfirmUseCase = MockConfirmSessionUseCase();
    mockJoinWaitlistUseCase = MockJoinWaitlistUseCase();
    mockLeaveWaitlistUseCase = MockLeaveWaitlistUseCase();
    mockToggleReminderUseCase = MockToggleSessionReminderUseCase();
    mockStartSessionUseCase = MockStartSessionUseCase();
    mockCompleteSessionUseCase = MockCompleteSessionUseCase();
    mockGenerateCodeUseCase = MockGenerateVerificationCodeUseCase();
    mockVerifyAttendanceUseCase = MockVerifyAttendanceUseCase();

    bloc = SessionBloc(
      createSessionUseCase: mockCreateUseCase,
      updateSessionUseCase: mockUpdateUseCase,
      cancelSessionUseCase: mockCancelUseCase,
      getSessionByIdUseCase: mockGetByIdUseCase,
      getUserSessionsUseCase: mockGetUserSessionsUseCase,
      confirmSessionUseCase: mockConfirmUseCase,
      joinWaitlistUseCase: mockJoinWaitlistUseCase,
      leaveWaitlistUseCase: mockLeaveWaitlistUseCase,
      toggleSessionReminderUseCase: mockToggleReminderUseCase,
      startSessionUseCase: mockStartSessionUseCase,
      completeSessionUseCase: mockCompleteSessionUseCase,
      generateVerificationCodeUseCase: mockGenerateCodeUseCase,
      verifyAttendanceUseCase: mockVerifyAttendanceUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateSessionRequested', () {
    final event = CreateSessionRequested(
      matchId: 'match1',
      skillId: 'skill1',
      skillTitle: 'Flutter Development',
      initiatorId: 'user1',
      participantId: 'user2',
      participantName: 'User Two',
      scheduledStart: DateTime(2025, 2, 1, 10, 0),
      scheduledEnd: DateTime(2025, 2, 1, 11, 0),
      format: SessionFormat.online,
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionCreated] on success',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionCreated>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionError] on failure',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('UpdateSessionRequested', () {
    final event = UpdateSessionRequested(
      id: 'session1',
      meetingLink: 'https://zoom.us/j/456',
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionUpdated] on success',
      build: () {
        when(() => mockUpdateUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUpdated>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionError] on failure',
      build: () {
        when(() => mockUpdateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('CancelSessionRequested', () {
    final event = CancelSessionRequested(session: tSession);

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionCancelled] on success',
      build: () {
        when(() => mockCancelUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionCancelled>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockCancelUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('GetSessionByIdRequested', () {
    final event = GetSessionByIdRequested(id: 'session1');

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionLoaded] on success',
      build: () {
        when(() => mockGetByIdUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionLoaded>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionError] on failure',
      build: () {
        when(() => mockGetByIdUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('GetUserSessionsRequested', () {
    final event = GetUserSessionsRequested(userId: 'user1');

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, UserSessionsLoaded] on success',
      build: () {
        when(() => mockGetUserSessionsUseCase(any()))
            .thenAnswer((_) async => Right([tSession]));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<UserSessionsLoaded>().having(
          (s) => s.sessions,
          'sessions',
          [tSession],
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionError] on failure',
      build: () {
        when(() => mockGetUserSessionsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('ConfirmSessionRequested', () {
    final event = ConfirmSessionRequested(id: 'session1');

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionConfirmed] on success',
      build: () {
        when(() => mockConfirmUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionConfirmed>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockConfirmUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('JoinWaitlistRequested', () {
    final event = JoinWaitlistRequested(
      sessionId: 'session1',
      userId: 'user3',
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, WaitlistUpdated] on success',
      build: () {
        when(() => mockJoinWaitlistUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<WaitlistUpdated>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockJoinWaitlistUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('LeaveWaitlistRequested', () {
    final event = LeaveWaitlistRequested(
      sessionId: 'session1',
      userId: 'user3',
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, WaitlistUpdated] on success',
      build: () {
        when(() => mockLeaveWaitlistUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<WaitlistUpdated>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockLeaveWaitlistUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('ToggleSessionReminderRequested', () {
    final event = ToggleSessionReminderRequested(
      id: 'session1',
      enabled: false,
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionReminderToggled] on success',
      build: () {
        when(() => mockToggleReminderUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionReminderToggled>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockToggleReminderUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('StartSessionRequested', () {
    final event = StartSessionRequested(id: 'session1');

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionStarted] on success',
      build: () {
        when(() => mockStartSessionUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionStarted>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockStartSessionUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('CompleteSessionRequested', () {
    final event = CompleteSessionRequested(id: 'session1');

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionCompleted] on success',
      build: () {
        when(() => mockCompleteSessionUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionCompleted>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockCompleteSessionUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('GenerateVerificationCodeRequested', () {
    final event = GenerateVerificationCodeRequested(
      sessionId: 'session1',
      userId: 'user1',
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionUpdated] on success',
      build: () {
        when(() => mockGenerateCodeUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionUpdated>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockGenerateCodeUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });

  group('VerifyAttendanceRequested', () {
    final event = VerifyAttendanceRequested(
      sessionId: 'session1',
      userId: 'user1',
      code: '123456',
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionUpdated] on success',
      build: () {
        when(() => mockVerifyAttendanceUseCase(any()))
            .thenAnswer((_) async => Right(tSession));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionUpdated>().having(
          (s) => s.session,
          'session',
          tSession,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [SessionActionLoading, SessionError] on failure',
      build: () {
        when(() => mockVerifyAttendanceUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        isA<SessionActionLoading>(),
        isA<SessionError>(),
      ],
    );
  });
}
