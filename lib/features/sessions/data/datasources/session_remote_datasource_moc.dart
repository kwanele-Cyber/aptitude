import 'package:myapp/features/sessions/data/models/session_model.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource.dart';

class SessionRemoteDataSourceMock implements SessionRemoteDataSource {
  final List<SessionModel> _sessions = [];

  @override
  Future<SessionModel> createSession(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final model = SessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: data['matchId'] as String? ?? '',
      skillId: data['skillId'] as String? ?? '',
      skillTitle: data['skillTitle'] as String? ?? '',
      initiatorId: data['initiatorId'] as String? ?? '',
      participantId: data['participantId'] as String? ?? '',
      participantName: data['participantName'] as String? ?? '',
      scheduledStart: DateTime.parse(data['scheduledStart'] as String),
      scheduledEnd: DateTime.parse(data['scheduledEnd'] as String),
      format:
          SessionModel.parseFormat(data['format'] as String?),
      cancellationPolicy: SessionModel.parseCancellationPolicy(
          data['cancellationPolicy'] as String?),
      location: data['location'] as String?,
      meetingLink: data['meetingLink'] as String?,
      notes: data['notes'] as String?,
      recurrencePattern: SessionModel.parseRecurrencePattern(
          data['recurrencePattern'] as String?),
      maxParticipants: data['maxParticipants'] as int?,
      remindersEnabled: data['remindersEnabled'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
    );
    _sessions.add(model);
    return model;
  }

  @override
  Future<SessionModel> updateSession(
      String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) throw Exception('Session not found');

    final existing = _sessions[index];
    final updated = SessionModel(
      id: existing.id,
      matchId: data['matchId'] as String? ?? existing.matchId,
      skillId: data['skillId'] as String? ?? existing.skillId,
      skillTitle: data['skillTitle'] as String? ?? existing.skillTitle,
      initiatorId: data['initiatorId'] as String? ?? existing.initiatorId,
      participantId:
          data['participantId'] as String? ?? existing.participantId,
      participantName:
          data['participantName'] as String? ?? existing.participantName,
      scheduledStart: data['scheduledStart'] != null
          ? DateTime.parse(data['scheduledStart'] as String)
          : existing.scheduledStart,
      scheduledEnd: data['scheduledEnd'] != null
          ? DateTime.parse(data['scheduledEnd'] as String)
          : existing.scheduledEnd,
      format: data['format'] != null
          ? SessionModel.parseFormat(data['format'] as String?)
          : existing.format,
      status: data['status'] != null
          ? SessionModel.parseStatus(data['status'] as String?)
          : existing.status,
      cancellationPolicy: data['cancellationPolicy'] != null
          ? SessionModel.parseCancellationPolicy(
              data['cancellationPolicy'] as String?)
          : existing.cancellationPolicy,
      location: data['location'] as String? ?? existing.location,
      meetingLink: data['meetingLink'] as String? ?? existing.meetingLink,
      notes: data['notes'] as String? ?? existing.notes,
      recurrencePattern: data['recurrencePattern'] != null
          ? SessionModel.parseRecurrencePattern(
              data['recurrencePattern'] as String?)
          : existing.recurrencePattern,
      maxParticipants:
          data['maxParticipants'] as int? ?? existing.maxParticipants,
      waitlistUserIds: data['waitlistUserIds'] != null
          ? List<String>.from(data['waitlistUserIds'] as List)
          : existing.waitlistUserIds,
      remindersEnabled:
          data['remindersEnabled'] as bool? ?? existing.remindersEnabled,
      cancelledAt: data['cancelledAt'] != null
          ? DateTime.parse(data['cancelledAt'] as String)
          : existing.cancelledAt,
      cancelReason: data['cancelReason'] as String? ?? existing.cancelReason,
      confirmedAt: data['confirmedAt'] != null
          ? DateTime.parse(data['confirmedAt'] as String)
          : existing.confirmedAt,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _sessions[index] = updated;
    return updated;
  }

  @override
  Future<SessionModel> cancelSession(String id, String? reason) async {
    return updateSession(id, {
      'status': 'cancelled',
      'cancelledAt': DateTime.now().toIso8601String(),
      'cancelReason': reason,
    });
  }

  @override
  Future<SessionModel> getSessionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) throw Exception('Session not found');
    return _sessions[index];
  }

  @override
  Future<List<SessionModel>> getUserSessions(String userId,
      {SessionStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = _sessions.where(
      (s) => s.initiatorId == userId || s.participantId == userId,
    ).toList();
    if (status != null) {
      results = results.where((s) => s.status == status).toList();
    }
    results.sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));
    return results;
  }

  @override
  Future<SessionModel> joinWaitlist(String sessionId, String userId) async {
    final session = await getSessionById(sessionId);
    final updatedWaitlist = [...session.waitlistUserIds, userId];
    return updateSession(sessionId, {'waitlistUserIds': updatedWaitlist});
  }

  @override
  Future<SessionModel> leaveWaitlist(String sessionId, String userId) async {
    final session = await getSessionById(sessionId);
    final updatedWaitlist =
        session.waitlistUserIds.where((id) => id != userId).toList();
    return updateSession(sessionId, {'waitlistUserIds': updatedWaitlist});
  }

  @override
  Future<SessionModel> confirmSession(String id) async {
    return updateSession(id, {
      'status': 'confirmed',
      'confirmedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<SessionModel> toggleReminders(String id, bool enabled) async {
    return updateSession(id, {'remindersEnabled': enabled});
  }

  @override
  Future<SessionModel> startSession(String id) async {
    return updateSession(id, {
      'status': 'inProgress',
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<SessionModel> completeSession(String id) async {
    return updateSession(id, {
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<SessionModel> generateVerificationCode(
      String sessionId, String userId) async {
    final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
    return updateSession(sessionId, {'verificationCode': code});
  }

  @override
  Future<SessionModel> verifyAttendance(
      String sessionId, String userId, String code) async {
    final session = await getSessionById(sessionId);
    if (session.verificationCode != code) {
      throw Exception('Invalid verification code');
    }
    final isInitiator = session.initiatorId == userId;
    if (isInitiator) {
      return updateSession(sessionId, {'initiatorVerified': true});
    } else {
      return updateSession(sessionId, {'participantVerified': true});
    }
  }
}
