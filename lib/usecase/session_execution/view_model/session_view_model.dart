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
  List<Session> get sessionHistory => _sessions
      .where(
        (session) =>
            session.status == SessionStatus.completed ||
            session.status == SessionStatus.cancelled,
      )
      .toList();

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
    _clearError();
    if (session.status == SessionStatus.cancelled) {
      _setError('Cancelled sessions cannot be completed');
      return;
    }

    final updated = session.copyWith(
      status: SessionStatus.completed,
      completedAt: DateTime.now(),
    );
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> startSession(Session session) async {
    _clearError();
    if (session.status != SessionStatus.scheduled) {
      _setError('Only scheduled sessions can be started');
      return;
    }

    final updated = session.copyWith(
      status: SessionStatus.inProgress,
      startedAt: DateTime.now(),
      verificationCode: _verificationCode(session),
    );
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  bool verifyAttendanceCode(Session session, String code) {
    final expected = session.verificationCode;
    return expected != null && expected == code.trim();
  }

  Future<void> checkInToSession({
    required Session session,
    required AttendanceVerificationMethod method,
    String? code,
    double? latitude,
    double? longitude,
  }) async {
    _clearError();
    final uid = await _currentUid();
    if (uid == null) {
      _setError('You must be signed in to check in');
      return;
    }
    if (session.status != SessionStatus.inProgress) {
      _setError('Session must be started before check-in');
      return;
    }
    if ((method == AttendanceVerificationMethod.code ||
            method == AttendanceVerificationMethod.qr) &&
        !verifyAttendanceCode(session, code ?? '')) {
      _setError('Invalid session verification code');
      return;
    }
    if (method == AttendanceVerificationMethod.geolocation &&
        (latitude == null || longitude == null)) {
      _setError('Location is required for geolocation check-in');
      return;
    }

    final attendeeIds = session.attendeeIds.contains(uid)
        ? session.attendeeIds
        : [...session.attendeeIds, uid];
    final attendanceRecords = Map<String, AttendanceRecord>.from(
      session.attendanceRecords,
    );
    attendanceRecords[uid] = AttendanceRecord(
      userId: uid,
      checkedInAt: DateTime.now(),
      method: method,
      verificationCode: code?.trim(),
      latitude: latitude,
      longitude: longitude,
    );

    final updated = session.copyWith(
      attendeeIds: attendeeIds,
      attendanceRecords: attendanceRecords,
    );
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
    _clearError();
    if (session.status != SessionStatus.completed) {
      _setError('Only completed sessions can be rated');
      return;
    }
    if (session.isRated) {
      _setError('This session has already been rated');
      return;
    }
    if (score < 1 || score > 5) {
      _setError('Session rating must be between 1 and 5');
      return;
    }

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

  String _verificationCode(Session session) {
    final source = '${session.id}-${DateTime.now().millisecondsSinceEpoch}';
    final hash = source.codeUnits.fold<int>(
      0,
      (value, unit) => (value * 31 + unit) & 0x7fffffff,
    );
    return (hash % 1000000).toString().padLeft(6, '0');
  }
}
