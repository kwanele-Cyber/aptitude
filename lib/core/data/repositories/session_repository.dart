import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class SessionRepository {
  final String _path = "sessions";
  late final DatabaseService<DataSnapshot> _databaseService;

  SessionRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> createSession(Session session) async {
    await _databaseService.create(
      location: "$_path/${session.agreementId}/${session.id}",
      data: session.toJson(),
    );
  }

  Future<List<Session>> getAgreementSessions(String agreementId) async {
    final snapshot = await _databaseService.list(location: "$_path/$agreementId");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((v) => Session.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return [];
  }

  Future<void> updateSession(Session session) async {
    await _databaseService.update(
      location: "$_path/${session.agreementId}/${session.id}",
      data: session.toJson(),
    );
  }

  Future<void> deleteSession(String agreementId, String sessionId) async {
    await _databaseService.delete(location: "$_path/$agreementId/$sessionId");
  }
}
