import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/models/session_model.dart';
import 'package:myapp/core/services/base_database_service.dart';

abstract class SessionRepository {
  Future<void> createSession(SessionModel session);
  Future<void> updateSessionStatus(String id, SessionStatus status);
  Future<List<SessionModel>> getSessionsByAgreement(String agreementId);
  Future<List<SessionModel>> getSessionsByUser(String userId);
}

class SessionRepositoryImpl extends BaseDatabaseService implements SessionRepository {
  SessionRepositoryImpl({super.database, super.pathPrefix});

  @override
  Future<void> createSession(SessionModel session) async {
    await setData(path: 'sessions/${session.id}', data: session.toJson());
  }

  @override
  Future<void> updateSessionStatus(String id, SessionStatus status) async {
    await updateData(
      path: 'sessions/$id',
      data: {'status': status.name},
    );
  }

  @override
  Future<List<SessionModel>> getSessionsByAgreement(String agreementId) async {
    try {
      final snapshot = await getData('sessions');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> sessionsMap = snapshot.value as Map;
        return sessionsMap.entries
            .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e.value as Map)))
            .where((s) => s.agreementId == agreementId)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SessionModel>> getSessionsByUser(String userId) async {
    // Note: In a real app, we'd use indexing. 
    // For now, we'll fetch all and filter or use a user-specific node.
    // However, sessions are linked to agreements, and agreements have participants.
    // To be efficient, we'd need to know which agreements the user is in.
    // For this initial version, we'll fetch all.
    try {
      final snapshot = await getData('sessions');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> sessionsMap = snapshot.value as Map;
        return sessionsMap.entries
            .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e.value as Map)))
            .toList(); // Filtering would happen in ViewModel or via cross-reference
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
