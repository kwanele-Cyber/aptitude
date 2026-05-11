import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/utils/geo_utils.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource.dart';
import 'package:myapp/features/matchmaking/data/models/match_model.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

class MatchRemoteDataSourceFirebase implements MatchRemoteDataSource {
  final FirebaseDatabase _database;

  MatchRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _matchesRef => _database.ref('matches');

  @override
  Future<void> saveMatch(MatchModel match) async {
    try {
      await _matchesRef.child(match.id).set(match.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> createDirectMatch(Map<String, dynamic> matchData) async {
    try {
      final ref = _matchesRef.push();
      final data = Map<String, dynamic>.from(matchData)
        ..putIfAbsent('id', () => ref.key);
      await ref.set(data);
      return ref.key ?? '';
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateMatchStatus(
      String matchId, Map<String, dynamic> data) async {
    try {
      await _matchesRef.child(matchId).update(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> saveFeedback(String matchId, Map<String, dynamic> data) async {
    try {
      await _matchesRef.child(matchId).child('feedback').set(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<MatchModel>> fetchMatchesForUser(String userId) async {
    try {
      final snapshot = await _matchesRef
          .orderByChild('targetUserId')
          .equalTo(userId)
          .get();
      if (!snapshot.exists) return [];

      final map = snapshot.value is Map ? Map<String, dynamic>.from(snapshot.value as Map) : null;
      if (map == null) return [];

      final matches = <MatchModel>[];
      map.forEach((key, value) {
        matches.add(
            MatchModel.fromJson(key, Map<String, dynamic>.from(value as Map)));
      });
      matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return matches;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<MatchModel>> generateMatches(
      String userId, List<SkillModel> allSkills) async {
    try {
      final matches = <MatchModel>[];
      final now = DateTime.now();
      final userSkills =
          allSkills.where((s) => s.userId == userId).toList();

      // Find current user's offers → match with others' requests
      final userOffers =
          userSkills.where((s) => s.type == SkillType.offer).toList();
      final otherRequests = allSkills
          .where((s) => s.userId != userId && s.type == SkillType.request)
          .toList();

      for (final offer in userOffers) {
        for (final request in otherRequests) {
          final result = _calculateMatchScore(offer, request);
          if (result.score >= 20) {
            matches.add(MatchModel(
              id: '${offer.id}_${request.id}',
              targetUserId: request.userId,
              targetSkillId: request.id,
              matchedSkillId: offer.id,
              score: result.score,
              status: MatchStatus.pending,
              createdAt: now,
              targetUserName: '',
              targetSkillTitle: request.title,
              targetSkillCategory: request.category,
              targetSkillLevel: request.level,
              targetSkillFormat: request.format,
              distance: result.distance,
              targetAvailability: result.commonAvailability,
            ));
          }
        }
      }

      // Find current user's requests → match with others' offers
      final userRequests =
          userSkills.where((s) => s.type == SkillType.request).toList();
      final otherOffers = allSkills
          .where((s) => s.userId != userId && s.type == SkillType.offer)
          .toList();

      for (final request in userRequests) {
        for (final offer in otherOffers) {
          final result = _calculateMatchScore(offer, request);
          if (result.score >= 20) {
            matches.add(MatchModel(
              id: '${request.id}_${offer.id}',
              targetUserId: offer.userId,
              targetSkillId: offer.id,
              matchedSkillId: request.id,
              score: result.score,
              status: MatchStatus.pending,
              createdAt: now,
              targetUserName: '',
              targetSkillTitle: offer.title,
              targetSkillCategory: offer.category,
              targetSkillLevel: offer.level,
              targetSkillFormat: offer.format,
              distance: result.distance,
              targetAvailability: result.commonAvailability,
            ));
          }
        }
      }

      // Sort by score descending and keep top 20
      matches.sort((a, b) => b.score.compareTo(a.score));
      final topMatches = matches.take(20).toList();

      // Persist to Firebase
      final batch = _database.ref().child('matches');
      for (final match in topMatches) {
        await batch.child(match.id).set(match.toJson());
      }

      return topMatches;
    } catch (e) {
      throw ServerException();
    }
  }

  ({double score, double? distance, List<String> commonAvailability})
      _calculateMatchScore(SkillModel a, SkillModel b) {
    double score = 0;

    // Category match: up to 30 points
    if (a.category.toLowerCase() == b.category.toLowerCase()) {
      score += 30;
    } else if (a.category.toLowerCase().contains(b.category.toLowerCase()) ||
        b.category.toLowerCase().contains(a.category.toLowerCase())) {
      score += 15;
    }

    // Level compatibility: up to 25 points
    final levelDiff = (a.level.index - b.level.index).abs();
    if (levelDiff == 0) {
      score += 25;
    } else if (levelDiff == 1) {
      score += 15;
    } else {
      score += 5;
    }

    // Format compatibility: up to 20 points
    if (a.format == b.format) {
      score += 20;
    } else if (a.format == SkillFormat.both || b.format == SkillFormat.both) {
      score += 10;
    }

    // Tag overlap: up to 15 points
    final commonTags = a.tags.where((t) => b.tags.contains(t)).length;
    score += (commonTags * 5).clamp(0, 15);

    // Geo-proximity: up to 10 points
    double? distance;
    if (a.latitude != null &&
        a.longitude != null &&
        b.latitude != null &&
        b.longitude != null) {
      distance = haversineDistance(
        a.latitude!,
        a.longitude!,
        b.latitude!,
        b.longitude!,
      );
      if (distance <= 5) {
        score += 10;
      } else if (distance <= 20) {
        score += 7;
      } else if (distance <= 50) {
        score += 4;
      } else {
        score += 1;
      }
    }

    // Availability overlap: up to 5 points
    final commonA = a.availability
        .where((slot) => b.availability.contains(slot))
        .toList();
    score += (commonA.length * 2).clamp(0, 5);

    return (score: score.clamp(0, 100).toDouble(), distance: distance,
        commonAvailability: commonA);
  }
}
