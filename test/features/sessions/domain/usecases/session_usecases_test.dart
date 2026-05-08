import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';
import 'package:myapp/features/sessions/domain/usecases/cancel_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/confirm_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/create_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_by_id_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/join_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/leave_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/toggle_session_reminder_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_usecase.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

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
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
  });

  group('CreateSessionUseCase', () {
    late CreateSessionUseCase useCase;
    CreateSessionParams params = CreateSessionParams(
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

    setUp(() {
      useCase = CreateSessionUseCase(repository: mockRepository);
    });

    test('should create session on success', () async {
      when(
        () => mockRepository.createSession(any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.createSession(any())).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.createSession(any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('UpdateSessionUseCase', () {
    late UpdateSessionUseCase useCase;
    UpdateSessionParams params = UpdateSessionParams(
      id: 'session1',
      meetingLink: 'https://zoom.us/j/456',
    );

    setUp(() {
      useCase = UpdateSessionUseCase(repository: mockRepository);
    });

    test('should update session on success', () async {
      when(
        () => mockRepository.updateSession(any(), any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(
        () => mockRepository.updateSession('session1', {
          'meetingLink': 'https://zoom.us/j/456',
        }),
      ).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.updateSession(any(), any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('CancelSessionUseCase', () {
    late CancelSessionUseCase useCase;

    setUp(() {
      useCase = CancelSessionUseCase(repository: mockRepository);
    });

    test('should cancel session on success', () async {
      final cancelableSession = tSession.copyWith(
        cancellationPolicy: CancellationPolicy.flexible,
      );
      when(
        () => mockRepository.cancelSession(any(), any()),
      ).thenAnswer((_) async => Right(cancelableSession));

      final result = await useCase(
        CancelSessionParams(session: cancelableSession),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.cancelSession('session1', null)).called(1);
    });

    test('should return Failure when repository fails', () async {
      final cancelableSession = tSession.copyWith(
        cancellationPolicy: CancellationPolicy.flexible,
      );
      when(
        () => mockRepository.cancelSession(any(), any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        CancelSessionParams(session: cancelableSession),
      );

      expect(result.isLeft(), true);
    });

    test(
      'should return Failure when cancellation policy prevents cancel',
      () async {
        final pastSession = tSession.copyWith(
          scheduledStart: DateTime.now().add(const Duration(hours: 1)),
          cancellationPolicy: CancellationPolicy.strict,
        );

        final result = await useCase(CancelSessionParams(session: pastSession));

        expect(result.isLeft(), true);
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        verifyNever(() => mockRepository.cancelSession(any(), any()));
      },
    );
  });

  group('GetSessionByIdUseCase', () {
    late GetSessionByIdUseCase useCase;
    GetSessionByIdParams params = GetSessionByIdParams(id: 'session1');

    setUp(() {
      useCase = GetSessionByIdUseCase(repository: mockRepository);
    });

    test('should get session by id on success', () async {
      when(
        () => mockRepository.getSessionById(any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getSessionById('session1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.getSessionById(any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('GetUserSessionsUseCase', () {
    late GetUserSessionsUseCase useCase;

    setUp(() {
      useCase = GetUserSessionsUseCase(repository: mockRepository);
    });

    test('should get user sessions on success', () async {
      when(
        () =>
            mockRepository.getUserSessions(any(), status: any(named: 'status')),
      ).thenAnswer((_) async => Right([tSession]));

      final result = await useCase(
        GetUserSessionsParams(userId: 'user1', status: SessionStatus.scheduled),
      );

      expect(result.isRight(), true);
      verify(
        () => mockRepository.getUserSessions(
          'user1',
          status: SessionStatus.scheduled,
        ),
      ).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () =>
            mockRepository.getUserSessions(any(), status: any(named: 'status')),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(GetUserSessionsParams(userId: 'user1'));

      expect(result.isLeft(), true);
    });
  });

  group('ConfirmSessionUseCase', () {
    late ConfirmSessionUseCase useCase;
    ConfirmSessionParams params = ConfirmSessionParams(id: 'session1');

    setUp(() {
      useCase = ConfirmSessionUseCase(repository: mockRepository);
    });

    test('should confirm session on success', () async {
      when(
        () => mockRepository.confirmSession(any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.confirmSession('session1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.confirmSession(any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('JoinWaitlistUseCase', () {
    late JoinWaitlistUseCase useCase;

    setUp(() {
      useCase = JoinWaitlistUseCase(repository: mockRepository);
    });

    test('should join waitlist on success', () async {
      when(
        () => mockRepository.joinWaitlist(any(), any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(
        JoinWaitlistParams(sessionId: 'session1', userId: 'user3'),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.joinWaitlist('session1', 'user3')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.joinWaitlist(any(), any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        JoinWaitlistParams(sessionId: 'session1', userId: 'user3'),
      );

      expect(result.isLeft(), true);
    });
  });

  group('LeaveWaitlistUseCase', () {
    late LeaveWaitlistUseCase useCase;

    setUp(() {
      useCase = LeaveWaitlistUseCase(repository: mockRepository);
    });

    test('should leave waitlist on success', () async {
      when(
        () => mockRepository.leaveWaitlist(any(), any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(
        LeaveWaitlistParams(sessionId: 'session1', userId: 'user3'),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.leaveWaitlist('session1', 'user3')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.leaveWaitlist(any(), any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        LeaveWaitlistParams(sessionId: 'session1', userId: 'user3'),
      );

      expect(result.isLeft(), true);
    });
  });

  group('ToggleSessionReminderUseCase', () {
    late ToggleSessionReminderUseCase useCase;

    setUp(() {
      useCase = ToggleSessionReminderUseCase(repository: mockRepository);
    });

    test('should toggle reminders on success', () async {
      when(
        () => mockRepository.toggleReminders(any(), any()),
      ).thenAnswer((_) async => Right(tSession));

      final result = await useCase(
        ToggleSessionReminderParams(id: 'session1', enabled: false),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.toggleReminders('session1', false)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.toggleReminders(any(), any()),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        ToggleSessionReminderParams(id: 'session1', enabled: false),
      );

      expect(result.isLeft(), true);
    });
  });
}
