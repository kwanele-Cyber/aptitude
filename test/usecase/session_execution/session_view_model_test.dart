import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/rating.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/core/data/repositories/rating_repository.dart';
import 'package:myapp/core/data/repositories/session_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/usecase/session_execution/view_model/session_view_model.dart';

void main() {
  late FakeSessionRepository sessionRepo;
  late FakeRatingRepository ratingRepo;
  late SessionViewModel viewModel;

  setUp(() {
    sessionRepo = FakeSessionRepository();
    ratingRepo = FakeRatingRepository();
    viewModel = SessionViewModel(
      agreementId: 'agreement_1',
      sessionRepo: sessionRepo,
      ratingRepo: ratingRepo,
      currentUidProvider: () async => 'user_1',
    );
  });

  group('SessionViewModel scheduling use cases', () {
    test(
      'scheduleSession creates a session with format, reminders, and calendar sync',
      () async {
        await viewModel.scheduleSession(
          title: 'Intro to guitar',
          startTime: DateTime.now().add(const Duration(days: 2)),
          durationMinutes: 60,
          location: 'Meet link',
          format: SessionFormat.online,
          reminderOffsetsMinutes: const [1440, 60],
          calendarSyncEnabled: true,
          capacity: 3,
        );

        expect(sessionRepo.sessions, hasLength(1));
        expect(sessionRepo.sessions.single.title, 'Intro to guitar');
        expect(sessionRepo.sessions.single.calendarSyncEnabled, true);
        expect(sessionRepo.sessions.single.capacity, 3);
      },
    );

    test(
      'updateSessionDetails modifies time, location, format, reminders, and capacity',
      () async {
        final session = _session(
          startTime: DateTime.now().add(const Duration(days: 2)),
        );
        sessionRepo.sessions.add(session);

        final updatedStart = DateTime.now().add(const Duration(days: 3));
        await viewModel.updateSessionDetails(
          session: session,
          title: 'Updated session',
          startTime: updatedStart,
          durationMinutes: 90,
          location: 'Room 12',
          format: SessionFormat.inPerson,
          reminderOffsetsMinutes: const [60],
          calendarSyncEnabled: true,
          capacity: 4,
        );

        final updated = sessionRepo.sessions.single;
        expect(updated.title, 'Updated session');
        expect(updated.startTime, updatedStart);
        expect(updated.location, 'Room 12');
        expect(updated.format, SessionFormat.inPerson);
        expect(updated.reminderOffsetsMinutes, [60]);
        expect(updated.capacity, 4);
      },
    );

    test('cancelSession enforces a two hour cancellation policy', () async {
      final soon = _session(
        startTime: DateTime.now().add(const Duration(minutes: 30)),
      );
      sessionRepo.sessions.add(soon);

      await viewModel.cancelSession(soon);

      expect(sessionRepo.sessions.single.status, SessionStatus.scheduled);
      expect(viewModel.errorMessage, contains('2 hours'));
    });

    test('cancelSession cancels sessions outside the policy window', () async {
      final future = _session(
        startTime: DateTime.now().add(const Duration(days: 2)),
      );
      sessionRepo.sessions.add(future);

      await viewModel.cancelSession(future);

      expect(sessionRepo.sessions.single.status, SessionStatus.cancelled);
    });

    test(
      'scheduleRecurringSessions creates weekly sessions in one recurrence group',
      () async {
        final firstStart = DateTime.now().add(const Duration(days: 2));

        await viewModel.scheduleRecurringSessions(
          title: 'Weekly swap',
          firstStartTime: firstStart,
          durationMinutes: 60,
          location: 'Online',
          format: SessionFormat.online,
          occurrences: 3,
        );

        expect(sessionRepo.sessions, hasLength(3));
        expect(
          sessionRepo.sessions[1].startTime,
          firstStart.add(const Duration(days: 7)),
        );
        expect(
          sessionRepo.sessions.map((s) => s.recurrenceGroupId).toSet(),
          hasLength(1),
        );
      },
    );

    test('buildCalendarInvite creates an ICS event payload', () {
      final session = _session(
        title: 'Calendar session',
        startTime: DateTime.utc(2026, 5, 4, 10),
        location: 'Online',
      );

      final invite = viewModel.buildCalendarInvite(session);

      expect(invite, contains('BEGIN:VCALENDAR'));
      expect(invite, contains('SUMMARY:Calendar session'));
      expect(invite, contains('DTSTART:20260504T100000Z'));
    });

    test('joinWaitlist adds current user when the session is full', () async {
      final full = _session(capacity: 1, attendeeIds: const ['attendee_1']);
      sessionRepo.sessions.add(full);

      await viewModel.joinWaitlist(full);

      expect(sessionRepo.sessions.single.waitlistUserIds, ['user_1']);
    });

    test(
      'startSession begins a scheduled session with a verification code',
      () async {
        final session = _session();
        sessionRepo.sessions.add(session);

        await viewModel.startSession(session);

        final started = sessionRepo.sessions.single;
        expect(started.status, SessionStatus.inProgress);
        expect(started.startedAt, isNotNull);
        expect(started.verificationCode, hasLength(6));
      },
    );

    test('checkInToSession rejects an invalid verification code', () async {
      final session = _session(
        status: SessionStatus.inProgress,
        verificationCode: '123456',
      );
      sessionRepo.sessions.add(session);

      await viewModel.checkInToSession(
        session: session,
        method: AttendanceVerificationMethod.code,
        code: '000000',
      );

      expect(sessionRepo.sessions.single.attendeeIds, isEmpty);
      expect(viewModel.errorMessage, 'Invalid session verification code');
    });

    test('checkInToSession tracks attendance with code proof', () async {
      final session = _session(
        status: SessionStatus.inProgress,
        verificationCode: '123456',
      );
      sessionRepo.sessions.add(session);

      await viewModel.checkInToSession(
        session: session,
        method: AttendanceVerificationMethod.code,
        code: '123456',
      );

      final updated = sessionRepo.sessions.single;
      expect(updated.attendeeIds, ['user_1']);
      expect(
        updated.attendanceRecords['user_1']?.method,
        AttendanceVerificationMethod.code,
      );
      expect(updated.attendanceRecords['user_1']?.verificationCode, '123456');
    });

    test('checkInToSession tracks geolocation attendance proof', () async {
      final session = _session(status: SessionStatus.inProgress);
      sessionRepo.sessions.add(session);

      await viewModel.checkInToSession(
        session: session,
        method: AttendanceVerificationMethod.geolocation,
        latitude: -26.2041,
        longitude: 28.0473,
      );

      final record = sessionRepo.sessions.single.attendanceRecords['user_1'];
      expect(record?.method, AttendanceVerificationMethod.geolocation);
      expect(record?.latitude, -26.2041);
      expect(record?.longitude, 28.0473);
    });

    test(
      'completeSession marks session complete with completion time',
      () async {
        final session = _session(status: SessionStatus.inProgress);
        sessionRepo.sessions.add(session);

        await viewModel.completeSession(session);

        expect(sessionRepo.sessions.single.status, SessionStatus.completed);
        expect(sessionRepo.sessions.single.completedAt, isNotNull);
      },
    );

    test('sessionHistory returns completed and cancelled sessions', () async {
      final scheduled = _session(id: 'scheduled');
      final completed = _session(
        id: 'completed',
        status: SessionStatus.completed,
      );
      final cancelled = _session(
        id: 'cancelled',
        status: SessionStatus.cancelled,
      );
      sessionRepo.sessions.addAll([scheduled, completed, cancelled]);

      await viewModel.loadSessions();

      expect(viewModel.sessionHistory.map((session) => session.id), [
        'completed',
        'cancelled',
      ]);
    });

    test('submitRating only allows completed sessions', () async {
      final session = _session(status: SessionStatus.inProgress);
      sessionRepo.sessions.add(session);

      await viewModel.submitRating(
        session: session,
        fromUid: 'user_1',
        toUid: 'user_2',
        score: 5,
        comment: 'Great',
      );

      expect(ratingRepo.ratings, isEmpty);
      expect(viewModel.errorMessage, 'Only completed sessions can be rated');
    });

    test('submitRating records feedback and marks session as rated', () async {
      final session = _session(status: SessionStatus.completed);
      sessionRepo.sessions.add(session);

      await viewModel.submitRating(
        session: session,
        fromUid: 'user_1',
        toUid: 'user_2',
        score: 4,
        comment: 'Useful session',
      );

      expect(ratingRepo.ratings, hasLength(1));
      expect(ratingRepo.ratings.single.score, 4);
      expect(sessionRepo.sessions.single.isRated, true);
    });
  });
}

Session _session({
  String id = 'session_1',
  String title = 'Skill session',
  DateTime? startTime,
  String location = 'Online',
  int capacity = 2,
  List<String> attendeeIds = const [],
  SessionStatus status = SessionStatus.scheduled,
  String? verificationCode,
}) {
  return Session(
    id: id,
    agreementId: 'agreement_1',
    title: title,
    startTime: startTime ?? DateTime.now().add(const Duration(days: 1)),
    durationMinutes: 60,
    location: location,
    capacity: capacity,
    attendeeIds: attendeeIds,
    status: status,
    verificationCode: verificationCode,
  );
}

class FakeSessionRepository extends SessionRepository {
  FakeSessionRepository() : super(databaseService: _NoopDatabaseService());

  final List<Session> sessions = [];

  @override
  Future<void> createSession(Session session) async {
    sessions.add(session);
  }

  @override
  Future<List<Session>> getAgreementSessions(String agreementId) async {
    return sessions
        .where((session) => session.agreementId == agreementId)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<void> updateSession(Session session) async {
    final index = sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      sessions.add(session);
    } else {
      sessions[index] = session;
    }
  }
}

class FakeRatingRepository extends RatingRepository {
  FakeRatingRepository() : super(databaseService: _NoopDatabaseService());

  final List<Rating> ratings = [];

  @override
  Future<void> submitRating(Rating rating) async {
    ratings.add(rating);
  }
}

class _NoopDatabaseService implements DatabaseService<DataSnapshot> {
  @override
  Future<void> create({
    required String location,
    required Map<String, dynamic> data,
  }) async {}

  @override
  Future<void> delete({required String location}) async {}

  @override
  Future<DataSnapshot?> list({required String location}) async => null;

  @override
  Future<DataSnapshot?> read({required String location}) async => null;

  @override
  Future<void> update({
    required String location,
    required Map<String, dynamic> data,
  }) async {}
}
