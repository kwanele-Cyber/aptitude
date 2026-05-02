import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/core/data/models/rating.dart';
import 'package:myapp/core/data/repositories/session_repository.dart';
import 'package:myapp/core/data/repositories/rating_repository.dart';
import 'package:uuid/uuid.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionRepository _sessionRepo = SessionRepository();
  final RatingRepository _ratingRepo = RatingRepository();
  final String agreementId;

  SessionViewModel({required this.agreementId});

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _sessionRepo.getAgreementSessions(agreementId);
    } catch (e) {
      debugPrint('Error loading sessions: $e');
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
  }) async {
    final session = Session(
      id: const Uuid().v4(),
      agreementId: agreementId,
      title: title,
      startTime: startTime,
      durationMinutes: durationMinutes,
      location: location,
    );

    await _sessionRepo.createSession(session);
    await loadSessions();
  }

  Future<void> completeSession(Session session) async {
    final updated = session.copyWith(status: SessionStatus.completed);
    await _sessionRepo.updateSession(updated);
    await loadSessions();
  }

  Future<void> cancelSession(Session session) async {
    final updated = session.copyWith(status: SessionStatus.cancelled);
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
}
