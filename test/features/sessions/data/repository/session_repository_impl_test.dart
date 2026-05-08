import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource.dart';
import 'package:myapp/features/sessions/data/models/session_model.dart';
import 'package:myapp/features/sessions/data/repository/session_repository_impl.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

class MockSessionRemoteDataSource extends Mock
    implements SessionRemoteDataSource {}

final tSessionModel = SessionModel(
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
  location: null,
  meetingLink: 'https://zoom.us/j/123',
  notes: null,
  recurrencePattern: RecurrencePattern.none,
  maxParticipants: null,
  waitlistUserIds: [],
  remindersEnabled: true,
  cancelledAt: null,
  cancelReason: null,
  confirmedAt: null,
  createdAt: DateTime(2025, 1, 28),
  updatedAt: DateTime(2025, 1, 28),
);

void main() {
  late SessionRepositoryImpl repository;
  late MockSessionRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockSessionRemoteDataSource();
    repository = SessionRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('createSession', () {
    final data = {
      'matchId': 'match1',
      'skillId': 'skill1',
      'skillTitle': 'Flutter Development',
      'initiatorId': 'user1',
      'participantId': 'user2',
      'participantName': 'User Two',
    };

    test('should create session on success', () async {
      when(() => mockRemote.createSession(any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.createSession(data);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tSessionModel), isA<SessionEntity>());
      verify(() => mockRemote.createSession(data)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.createSession(any()))
          .thenThrow(ServerException());

      final result = await repository.createSession(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.createSession(any())).thenThrow(Exception());

      final result = await repository.createSession(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateSession', () {
    test('should update session on success', () async {
      when(() => mockRemote.updateSession(any(), any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.updateSession('session1', {
        'meetingLink': 'https://zoom.us/j/456',
      });

      expect(result.isRight(), true);
      verify(() => mockRemote.updateSession('session1', {
        'meetingLink': 'https://zoom.us/j/456',
      })).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.updateSession(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.updateSession('session1', {});

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateSession(any(), any()))
          .thenThrow(Exception());

      final result = await repository.updateSession('session1', {});

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('cancelSession', () {
    test('should cancel session on success', () async {
      when(() => mockRemote.cancelSession(any(), any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.cancelSession('session1', null);

      expect(result.isRight(), true);
      verify(() => mockRemote.cancelSession('session1', null)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.cancelSession(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.cancelSession('session1', null);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getSessionById', () {
    test('should get session by id on success', () async {
      when(() => mockRemote.getSessionById(any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.getSessionById('session1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tSessionModel), isA<SessionEntity>());
      verify(() => mockRemote.getSessionById('session1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getSessionById(any()))
          .thenThrow(ServerException());

      final result = await repository.getSessionById('session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getUserSessions', () {
    test('should get user sessions on success', () async {
      when(() => mockRemote.getUserSessions(any(), status: any(named: 'status')))
          .thenAnswer((_) async => [tSessionModel]);

      final result =
          await repository.getUserSessions('user1', status: SessionStatus.scheduled);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<SessionEntity>>());
      verify(() => mockRemote.getUserSessions('user1',
              status: SessionStatus.scheduled)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.getUserSessions(any(), status: any(named: 'status')))
          .thenThrow(ServerException());

      final result = await repository.getUserSessions('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('joinWaitlist', () {
    test('should join waitlist on success', () async {
      when(() => mockRemote.joinWaitlist(any(), any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.joinWaitlist('session1', 'user3');

      expect(result.isRight(), true);
      verify(() => mockRemote.joinWaitlist('session1', 'user3')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.joinWaitlist(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.joinWaitlist('session1', 'user3');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('leaveWaitlist', () {
    test('should leave waitlist on success', () async {
      when(() => mockRemote.leaveWaitlist(any(), any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.leaveWaitlist('session1', 'user3');

      expect(result.isRight(), true);
      verify(() => mockRemote.leaveWaitlist('session1', 'user3')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.leaveWaitlist(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.leaveWaitlist('session1', 'user3');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('confirmSession', () {
    test('should confirm session on success', () async {
      when(() => mockRemote.confirmSession(any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.confirmSession('session1');

      expect(result.isRight(), true);
      verify(() => mockRemote.confirmSession('session1')).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.confirmSession(any()))
          .thenThrow(ServerException());

      final result = await repository.confirmSession('session1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('toggleReminders', () {
    test('should toggle reminders on success', () async {
      when(() => mockRemote.toggleReminders(any(), any()))
          .thenAnswer((_) async => tSessionModel);

      final result = await repository.toggleReminders('session1', false);

      expect(result.isRight(), true);
      verify(() => mockRemote.toggleReminders('session1', false)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.toggleReminders(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.toggleReminders('session1', false);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
