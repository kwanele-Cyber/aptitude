import 'package:flutter/material.dart';
import 'package:myapp/core/models/session_model.dart';
import 'package:myapp/core/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionRepository _sessionRepository;

  SessionViewModel(this._sessionRepository);

  List<SessionModel> _sessions = [];
  List<SessionModel> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadSessionsForAgreement(String agreementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _sessionRepository.getSessionsByAgreement(agreementId);
    } catch (e) {
      debugPrint("Error loading sessions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scheduleSession({
    required String agreementId,
    required String title,
    required DateTime startTime,
    required double duration,
    String? notes,
  }) async {
    final session = SessionModel(
      id: const Uuid().v4(),
      agreementId: agreementId,
      title: title,
      startTime: startTime,
      duration: duration,
      notes: notes,
    );

    try {
      await _sessionRepository.createSession(session);
      _sessions.add(session);
      notifyListeners();
    } catch (e) {
      debugPrint("Error scheduling session: $e");
    }
  }

  Future<void> completeSession(String sessionId) async {
    try {
      await _sessionRepository.updateSessionStatus(sessionId, SessionStatus.completed);
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(status: SessionStatus.completed);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error completing session: $e");
    }
  }

  Future<void> cancelSession(String sessionId) async {
    try {
      await _sessionRepository.updateSessionStatus(sessionId, SessionStatus.canceled);
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(status: SessionStatus.canceled);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error canceling session: $e");
    }
  }
}
