import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/core/data/models/rating.dart';
import 'package:myapp/core/data/repositories/session_repository.dart';
import 'package:myapp/core/data/repositories/rating_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class SessionViewModel extends ChangeNotifier {
  static const int minimumCancellationNoticeMinutes = 120;

  final SessionRepository _sessionRepo;
  final RatingRepository _ratingRepo;
  final AuthService? _auth;
  final Future<String?> Function()? _currentUidProvider;
  final String agreementId;

  SessionViewModel({
    required this.agreementId,
    SessionRepository? sessionRepo,
    RatingRepository? ratingRepo,
    AuthService? auth,
    Future<String?> Function()? currentUidProvider,
  }) : _sessionRepo = sessionRepo ?? SessionRepository(),
       _ratingRepo = ratingRepo ?? RatingRepository(),
       _auth = auth,
       _currentUidProvider = currentUidProvider;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _sessions = await _sessionRepo.getAgreementSessions(agreementId);
    } catch (e) {
      _errorMessage = 'Could not load sessions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scheduleSession({
    required String title,
    required DateTime startTime,
    required int durationMinutes,
    required String location,
    SessionFormat format = SessionFormat.online,
    List<int> reminderOffsetsMinutes = const [1440, 60],
    bool calendarSyncEnabled = false,
    int capacity = 2,
  }) async {
    _clearError();
    if (!_validateSessionInput(title, startTime, durationMinutes, capacity)) {
      return;
    }

    final session = Session(
      id: const Uuid().v4(),
      agreementId: agreementId,
      title: title.trim(),
      startTime: startTime,
      durationMinutes: durationMinutes,
      format: format,
      location: location.trim().isEmpty ? 'Online' : location.trim(),
      reminderOffsetsMinutes: reminderOffsetsMinutes,
      calendarSyncEnabled: calendarSyncEnabled,
      capacity: capacity,
    );

    await _sessionRepo.createSession(session);
    await loadSessions();
  }

  Future<void> scheduleRecurringSessions({
    required String title,
    required DateTime firstStartTime,
    required int durationMinutes,
    required String location,
    required SessionFormat format,
    required int occurrences,
    List<int> reminderOffsetsMinutes = const [1440, 60],
    bool calendarSyncEnabled = false,
    int capacity = 2,
  }) async {
    _clearError();
    if (occurrences < 1) {
      _setError('Recurring sessions must include at least one occurrence');
      return;
    }
    if (!_validateSessionInput(
      title,
      firstStartTime,
      durationMinutes,
      capacity,
    )) {
      return;
    }

    final recurrenceGroupId = const Uuid().v4();
    for (var index = 0; index < occurrences; index++) {
      final session = Session(
        id: const Uuid().v4(),
        agreementId: agreementId,
        title: title.trim(),
        startTime: firstStartTime.add(Duration(days: 7 * index)),
        durationMinutes: durationMinutes,
        format: format,
        location: location.trim().isEmpty ? 'Online' : location.trim(),
        reminderOffsetsMinutes: reminderOffsetsMinutes,
        calendarSyncEnabled: calendarSyncEnabled,
        capacity: capacity,
        recurrenceGroupId: recurrenceGroupId,
      );
      await _sessionRepo.createSession(session);
    }

    await loadSessions();
  }

  Future<void> updateSessionDetails({
    required Session session,
    required String title,
    required DateTime startTime,
    required int durationMinutes,
    required String location,
    required SessionFormat format,
    required List<int> reminderOffsetsMinutes,
    required bool calendarSyncEnabled,
    required int capacity,
  }) async {
    _clearError();
    if (session.status != SessionStatus.scheduled) {
      _setError('Only scheduled sessions can be updated');
      return;
    }
    if (!_validateSessionInput(title, startTime, durationMinutes, capacity)) {
      return;
    }

    final updated = session.copyWith(
      title: title.trim(),
      startTime: startTime,
      durationMinutes: durationMinutes,
      location: location.trim().isEmpty ? 'Online' : location.trim(),
      format: format,
      reminderOffsetsMinutes: reminderOffsetsMinutes,
      calendarSyncEnabled: calendarSyncEnabled,
      capacity: capacity,
    );
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> completeSession(Session session) async {
    final updated = session.copyWith(status: SessionStatus.completed);
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> cancelSession(Session session) async {
    _clearError();
    if (!_canCancel(session)) {
      _setError(
        'Sessions can only be cancelled more than 2 hours before they start',
      );
      return;
    }

    final updated = session.copyWith(status: SessionStatus.cancelled);
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> updateReminderPreferences(
    Session session,
    List<int> reminderOffsetsMinutes,
  ) async {
    _clearError();
    final normalized = reminderOffsetsMinutes.toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final updated = session.copyWith(reminderOffsetsMinutes: normalized);
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> setCalendarSync(Session session, bool enabled) async {
    _clearError();
    final updated = session.copyWith(calendarSyncEnabled: enabled);
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  String buildCalendarInvite(Session session) {
    final start = _calendarDate(session.startTime);
    final end = _calendarDate(
      session.startTime.add(Duration(minutes: session.durationMinutes)),
    );
    final title = _escapeCalendarText(session.title);
    final location = _escapeCalendarText(session.location);
    final description = _escapeCalendarText(
      'Aptitude skill-sharing session for agreement $agreementId.',
    );

    return [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Aptitude//Session Scheduler//EN',
      'BEGIN:VEVENT',
      'UID:${session.id}@aptitude.local',
      'DTSTAMP:${_calendarDate(DateTime.now().toUtc())}',
      'DTSTART:$start',
      'DTEND:$end',
      'SUMMARY:$title',
      'LOCATION:$location',
      'DESCRIPTION:$description',
      'END:VEVENT',
      'END:VCALENDAR',
    ].join('\r\n');
  }

  Future<void> joinWaitlist(Session session) async {
    _clearError();
    final uid = await _currentUid();
    if (uid == null) {
      _setError('You must be signed in to join a waitlist');
      return;
    }
    if (!session.isFull) {
      _setError('This session still has available seats');
      return;
    }
    if (session.waitlistUserIds.contains(uid)) {
      return;
    }

    final updated = session.copyWith(
      waitlistUserIds: [...session.waitlistUserIds, uid],
    );
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> leaveWaitlist(Session session) async {
    _clearError();
    final uid = await _currentUid();
    if (uid == null) return;

    final updated = session.copyWith(
      waitlistUserIds: session.waitlistUserIds
          .where((item) => item != uid)
          .toList(),
    );
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> submitRating({
    required Session session,
    required String fromUid,
    required String toUid,
    required double score,
    required String comment,
  }) async {
    final rating = Rating(
      id: const Uuid().v4(),
      sessionId: session.id,
      fromUid: fromUid,
      toUid: toUid,
      score: score,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _ratingRepo.submitRating(rating);

    // Mark session as rated
    final updated = session.copyWith(isRated: true);
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  bool _validateSessionInput(
    String title,
    DateTime startTime,
    int durationMinutes,
    int capacity,
  ) {
    if (title.trim().isEmpty) {
      _setError('Session title is required');
      return false;
    }
    if (startTime.isBefore(DateTime.now())) {
      _setError('Session time must be in the future');
      return false;
    }
    if (durationMinutes < 15) {
      _setError('Session duration must be at least 15 minutes');
      return false;
    }
    if (capacity < 1) {
      _setError('Session capacity must be at least 1');
      return false;
    }
    return true;
  }

  bool _canCancel(Session session) {
    if (session.status != SessionStatus.scheduled) return false;
    final latestCancellation = session.startTime.subtract(
      const Duration(minutes: minimumCancellationNoticeMinutes),
    );
    return DateTime.now().isBefore(latestCancellation);
  }

  String _calendarDate(DateTime dateTime) {
    final utc = dateTime.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}T'
        '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }

  String _escapeCalendarText(String text) {
    return text
        .replaceAll('\\', r'\\')
        .replaceAll(',', r'\,')
        .replaceAll(';', r'\;')
        .replaceAll('\n', r'\n');
  }

  Future<String?> _currentUid() async {
    if (_currentUidProvider != null) {
      return _currentUidProvider();
    }
    return (await (_auth ?? AuthService()).getCurrentUser())?.uid;
  }
}
