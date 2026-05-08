import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource.dart';
import 'package:myapp/features/sessions/data/models/session_model.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

class SessionRemoteDataSourceFirebase implements SessionRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  SessionRemoteDataSourceFirebase(
      {FirebaseAuth? auth, FirebaseDatabase? database})
      : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _sessionsRef => _database.ref('sessions');

  @override
  Future<SessionModel> createSession(Map<String, dynamic> data) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.push();
      final now = DateTime.now().toIso8601String();

      final sessionData = {
        ...data,
        'status': SessionStatus.scheduled.name,
        'waitlistUserIds': [],
        'createdAt': now,
        'updatedAt': now,
      };

      await sessionRef.set(sessionData);
      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();

      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> updateSession(
      String id, Map<String, dynamic> data) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.child(id);
      final updateData = {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await sessionRef.update(updateData);
      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();

      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> cancelSession(String id, String? reason) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.child(id);
      final updateData = <String, dynamic>{
        'status': SessionStatus.cancelled.name,
        'cancelledAt': DateTime.now().toIso8601String(),
        'cancelReason': reason,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await sessionRef.update(updateData);
      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();

      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> getSessionById(String id) async {
    try {
      final snapshot = await _sessionsRef.child(id).get();
      if (!snapshot.exists) throw ServerException();

      return SessionModel.fromJson(
        snapshot.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<SessionModel>> getUserSessions(String userId,
      {SessionStatus? status}) async {
    try {
      final snapshot = await _sessionsRef.get();
      if (!snapshot.exists) return [];

      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map == null) return [];

      final sessions = <SessionModel>[];
      map.forEach((key, value) {
        final data = Map<String, dynamic>.from(value as Map);
        final initiatorId = data['initiatorId'] as String?;
        final participantId = data['participantId'] as String?;

        if (initiatorId != userId && participantId != userId) return;

        final session = SessionModel.fromJson(key, data);
        if (status != null && session.status != status) return;
        sessions.add(session);
      });

      sessions.sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));
      return sessions;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> joinWaitlist(String sessionId, String userId) async {
    try {
      final sessionRef = _sessionsRef.child(sessionId);
      final snapshot = await sessionRef.child('waitlistUserIds').get();
      final currentList = snapshot.value is List
          ? List<String>.from(snapshot.value as List)
          : <String>[];

      if (currentList.contains(userId)) {
        final updatedSnapshot = await sessionRef.get();
        if (!updatedSnapshot.exists) throw ServerException();
        return SessionModel.fromJson(
          sessionRef.key ?? '',
          Map<String, dynamic>.from(updatedSnapshot.value as Map),
        );
      }

      currentList.add(userId);
      await sessionRef.child('waitlistUserIds').set(currentList);
      await sessionRef.child('updatedAt').set(DateTime.now().toIso8601String());

      final updatedSnapshot = await sessionRef.get();
      if (!updatedSnapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(updatedSnapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> leaveWaitlist(String sessionId, String userId) async {
    try {
      final sessionRef = _sessionsRef.child(sessionId);
      final snapshot = await sessionRef.child('waitlistUserIds').get();
      final currentList = snapshot.value is List
          ? List<String>.from(snapshot.value as List)
          : <String>[];

      currentList.remove(userId);
      await sessionRef.child('waitlistUserIds').set(currentList);
      await sessionRef.child('updatedAt').set(DateTime.now().toIso8601String());

      final updatedSnapshot = await sessionRef.get();
      if (!updatedSnapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(updatedSnapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> confirmSession(String id) async {
    try {
      final sessionRef = _sessionsRef.child(id);
      await sessionRef.update({
        'status': SessionStatus.confirmed.name,
        'confirmedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> toggleReminders(String id, bool enabled) async {
    try {
      final sessionRef = _sessionsRef.child(id);
      await sessionRef.update({
        'remindersEnabled': enabled,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> startSession(String id) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.child(id);
      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString();
      await sessionRef.update({
        'status': SessionStatus.inProgress.name,
        'startedAt': DateTime.now().toIso8601String(),
        'verificationCode': code,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> completeSession(String id) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.child(id);
      await sessionRef.update({
        'status': SessionStatus.completed.name,
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> generateVerificationCode(
      String sessionId, String userId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.child(sessionId);
      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString();
      await sessionRef.update({
        'verificationCode': code,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SessionModel> verifyAttendance(
      String sessionId, String userId, String code) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final sessionRef = _sessionsRef.child(sessionId);
      final snapshot = await sessionRef.get();
      if (!snapshot.exists) throw ServerException();

      final session = SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );

      if (session.verificationCode != code) {
        throw const ServerException('Invalid verification code');
      }

      final isInitiator = session.initiatorId == uid;
      await sessionRef.update({
        if (isInitiator) 'initiatorVerified': true else 'participantVerified': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final updatedSnapshot = await sessionRef.get();
      if (!updatedSnapshot.exists) throw ServerException();
      return SessionModel.fromJson(
        sessionRef.key ?? '',
        Map<String, dynamic>.from(updatedSnapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }
}
