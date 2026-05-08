import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/sessions/data/models/session_model.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

void main() {
  group('SessionModel', () {
    final tJson = {
      'matchId': 'match1',
      'skillId': 'skill1',
      'skillTitle': 'Flutter Development',
      'initiatorId': 'user1',
      'participantId': 'user2',
      'participantName': 'User Two',
      'scheduledStart': '2025-02-01T10:00:00.000',
      'scheduledEnd': '2025-02-01T11:00:00.000',
      'format': 'online',
      'status': 'scheduled',
      'cancellationPolicy': 'moderate',
      'location': null,
      'meetingLink': 'https://zoom.us/j/123',
      'notes': 'Bring your laptop',
      'recurrencePattern': 'none',
      'maxParticipants': null,
      'waitlistUserIds': [],
      'remindersEnabled': true,
      'cancelledAt': null,
      'cancelReason': null,
      'confirmedAt': null,
      'createdAt': '2025-01-28T10:00:00.000',
      'updatedAt': '2025-01-28T10:00:00.000',
    };

    test('fromJson should return a valid model', () {
      final model = SessionModel.fromJson('session1', tJson);

      expect(model.id, 'session1');
      expect(model.matchId, 'match1');
      expect(model.skillTitle, 'Flutter Development');
      expect(model.format, SessionFormat.online);
      expect(model.status, SessionStatus.scheduled);
      expect(model.cancellationPolicy, CancellationPolicy.moderate);
      expect(model.recurrencePattern, RecurrencePattern.none);
      expect(model.remindersEnabled, true);
      expect(model.waitlistUserIds, []);
    });

    test('toJson should return a valid JSON map', () {
      final model = SessionModel(
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
        notes: 'Bring your laptop',
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

      final json = model.toJson();

      expect(json['matchId'], 'match1');
      expect(json['skillTitle'], 'Flutter Development');
      expect(json['format'], 'online');
      expect(json['status'], 'scheduled');
      expect(json['cancellationPolicy'], 'moderate');
      expect(json['remindersEnabled'], true);
    });

    test('parseStatus should return correct enum values', () {
      expect(SessionModel.parseStatus('scheduled'), SessionStatus.scheduled);
      expect(SessionModel.parseStatus('confirmed'), SessionStatus.confirmed);
      expect(SessionModel.parseStatus('inProgress'), SessionStatus.inProgress);
      expect(SessionModel.parseStatus('completed'), SessionStatus.completed);
      expect(SessionModel.parseStatus('cancelled'), SessionStatus.cancelled);
      expect(SessionModel.parseStatus('noShow'), SessionStatus.noShow);
      expect(SessionModel.parseStatus(null), SessionStatus.scheduled);
      expect(SessionModel.parseStatus('unknown'), SessionStatus.scheduled);
    });

    test('parseFormat should return correct enum values', () {
      expect(SessionModel.parseFormat('online'), SessionFormat.online);
      expect(SessionModel.parseFormat('inPerson'), SessionFormat.inPerson);
      expect(SessionModel.parseFormat(null), SessionFormat.online);
      expect(SessionModel.parseFormat('unknown'), SessionFormat.online);
    });

    test('parseCancellationPolicy should return correct enum values', () {
      expect(SessionModel.parseCancellationPolicy('flexible'),
          CancellationPolicy.flexible);
      expect(SessionModel.parseCancellationPolicy('moderate'),
          CancellationPolicy.moderate);
      expect(SessionModel.parseCancellationPolicy('strict'),
          CancellationPolicy.strict);
      expect(SessionModel.parseCancellationPolicy(null),
          CancellationPolicy.moderate);
      expect(SessionModel.parseCancellationPolicy('unknown'),
          CancellationPolicy.moderate);
    });

    test('parseRecurrencePattern should return correct enum values', () {
      expect(SessionModel.parseRecurrencePattern('none'),
          RecurrencePattern.none);
      expect(SessionModel.parseRecurrencePattern('daily'),
          RecurrencePattern.daily);
      expect(SessionModel.parseRecurrencePattern('weekly'),
          RecurrencePattern.weekly);
      expect(SessionModel.parseRecurrencePattern('biweekly'),
          RecurrencePattern.biweekly);
      expect(SessionModel.parseRecurrencePattern('monthly'),
          RecurrencePattern.monthly);
      expect(SessionModel.parseRecurrencePattern(null),
          RecurrencePattern.none);
      expect(SessionModel.parseRecurrencePattern('unknown'),
          RecurrencePattern.none);
    });

    test('fromJson should parse confirmed status correctly', () {
      final confirmedJson = {...tJson, 'status': 'confirmed'};
      final model = SessionModel.fromJson('session1', confirmedJson);
      expect(model.status, SessionStatus.confirmed);
    });

    test('fromJson should parse inPerson format correctly', () {
      final inPersonJson = {...tJson, 'format': 'inPerson'};
      final model = SessionModel.fromJson('session1', inPersonJson);
      expect(model.format, SessionFormat.inPerson);
    });

    test('fromJson should handle waitlistUserIds', () {
      final waitlistJson = {
        ...tJson,
        'waitlistUserIds': ['user3', 'user4'],
      };
      final model = SessionModel.fromJson('session1', waitlistJson);
      expect(model.waitlistUserIds, ['user3', 'user4']);
    });

    test('fromJson should handle null fields gracefully', () {
      final minimalJson = {
        'matchId': 'match1',
        'skillId': 'skill1',
        'skillTitle': 'Skill',
        'initiatorId': 'user1',
        'participantId': 'user2',
        'participantName': 'User',
        'scheduledStart': '2025-02-01T10:00:00.000',
        'scheduledEnd': '2025-02-01T11:00:00.000',
        'createdAt': '2025-01-28T10:00:00.000',
        'updatedAt': '2025-01-28T10:00:00.000',
      };

      final model = SessionModel.fromJson('session1', minimalJson);

      expect(model.status, SessionStatus.scheduled);
      expect(model.format, SessionFormat.online);
      expect(model.cancellationPolicy, CancellationPolicy.moderate);
      expect(model.recurrencePattern, RecurrencePattern.none);
      expect(model.remindersEnabled, true);
      expect(model.waitlistUserIds, []);
      expect(model.location, isNull);
      expect(model.meetingLink, isNull);
      expect(model.notes, isNull);
    });
  });
}
