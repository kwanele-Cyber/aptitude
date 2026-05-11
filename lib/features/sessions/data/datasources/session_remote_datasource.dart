import 'package:myapp/features/sessions/data/models/session_model.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

abstract class SessionRemoteDataSource {
  Future<SessionModel> createSession(Map<String, dynamic> data);
  Future<SessionModel> updateSession(String id, Map<String, dynamic> data);
  Future<SessionModel> cancelSession(String id, String? reason);
  Future<SessionModel> getSessionById(String id);
  Future<List<SessionModel>> getUserSessions(String userId,
      {SessionStatus? status});
  Future<SessionModel> joinWaitlist(String sessionId, String userId);
  Future<SessionModel> leaveWaitlist(String sessionId, String userId);
  Future<SessionModel> confirmSession(String id);
  Future<SessionModel> toggleReminders(String id, bool enabled);
  Future<SessionModel> startSession(String id);
  Future<SessionModel> completeSession(String id);
  Future<SessionModel> generateVerificationCode(
      String sessionId, String userId);
  Future<SessionModel> verifyAttendance(
      String sessionId, String userId, String code);
}

