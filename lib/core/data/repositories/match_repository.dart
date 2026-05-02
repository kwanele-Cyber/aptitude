import 'package:myapp/core/data/models/match.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/core/error/app_exception.dart';

class MatchRepository {
  final String _basePath = "matches";
  final DatabaseService<DataSnapshot> _db;

  MatchRepository({DatabaseService<DataSnapshot>? db}) 
    : _db = db ?? FirebaseService();

  Future<void> createMatch(Match match) async {
    try {
      await _db.create(
        location: '$_basePath/${match.id}',
        data: match.toJson(),
      );
    } catch (e) {
      throw DatabaseException("Failed to create match record", ErrorCode.databaseError, e);
    }
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus status, String userId) async {
    try {
      await _db.update(
        location: '$_basePath/$matchId',
        data: {
          'status': status.name,
          'updatedAt': DateTime.now().toIso8601String(),
          'lastActionBy': userId,
        },
      );
    } catch (e) {
      throw DatabaseException("Failed to update match status", ErrorCode.databaseError, e);
    }
  }

  Future<Match?> findMatchByParticipants(String uid1, String uid2) async {
    final snapshot = await _db.list(location: _basePath);
    if (snapshot == null || !snapshot.exists || snapshot.value == null) return null;

    final Map<dynamic, dynamic> matchesMap = snapshot.value as Map;
    for (var entry in matchesMap.entries) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(uid1) && participants.contains(uid2)) {
        return Match.fromJson(data);
      }
    }
    return null;
  }

  Future<void> acceptMatch(String myUid, String peerUid) async {
    try {
      final existing = await findMatchByParticipants(myUid, peerUid);
      
      if (existing != null) {
        if (existing.status == MatchStatus.accepted) {
           throw MatchException("Match already accepted", ErrorCode.matchAlreadyExists);
        }
        await updateMatchStatus(existing.id, MatchStatus.accepted, myUid);
      } else {
        final newMatch = Match(
          id: const Uuid().v4(),
          participants: [myUid, peerUid],
          status: MatchStatus.accepted,
          createdAt: DateTime.now(),
          lastActionBy: myUid,
        );
        await createMatch(newMatch);
      }
    } catch (e) {
      if (e is MatchException) rethrow;
      throw MatchException("Failed to accept match", ErrorCode.unknown, e);
    }
  }

  Future<void> rejectMatch(String myUid, String peerUid) async {
    final existing = await findMatchByParticipants(myUid, peerUid);
    
    if (existing != null) {
      await updateMatchStatus(existing.id, MatchStatus.rejected, myUid);
    } else {
      final newMatch = Match(
        id: const Uuid().v4(),
        participants: [myUid, peerUid],
        status: MatchStatus.rejected,
        createdAt: DateTime.now(),
        lastActionBy: myUid,
      );
      await createMatch(newMatch);
    }
  }

  Future<void> ignoreMatch(String myUid, String peerUid) async {
    final existing = await findMatchByParticipants(myUid, peerUid);
    
    if (existing != null) {
      await updateMatchStatus(existing.id, MatchStatus.ignored, myUid);
    } else {
      final newMatch = Match(
        id: const Uuid().v4(),
        participants: [myUid, peerUid],
        status: MatchStatus.ignored,
        createdAt: DateTime.now(),
        lastActionBy: myUid,
      );
      await createMatch(newMatch);
    }
  }

  Future<void> saveMatch(String myUid, String peerUid) async {
    final existing = await findMatchByParticipants(myUid, peerUid);
    
    if (existing != null) {
      await updateMatchStatus(existing.id, MatchStatus.saved, myUid);
    } else {
      final newMatch = Match(
        id: const Uuid().v4(),
        participants: [myUid, peerUid],
        status: MatchStatus.saved,
        createdAt: DateTime.now(),
        lastActionBy: myUid,
      );
      await createMatch(newMatch);
    }
  }

  Future<List<Match>> getUserMatches(String uid) async {
    final snapshot = await _db.list(location: _basePath);
    if (snapshot == null || !snapshot.exists || snapshot.value == null) return [];

    final Map<dynamic, dynamic> matchesMap = snapshot.value as Map;
    List<Match> results = [];
    
    for (var entry in matchesMap.entries) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(uid)) {
        results.add(Match.fromJson(data));
      }
    }
    return results;
  }
}
