import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/models/match_model.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/repositories/skill_repository.dart';
import 'package:myapp/core/repositories/user_repository.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/services/location_service.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';

abstract class MatchRepository {
  Future<List<MatchModel>> generateMatches(String userId);
  Future<List<MatchModel>> getMatches(String userId);
  Future<void> updateMatchStatus(String matchId, String status);
}

class MatchRepositoryImpl extends BaseDatabaseService implements MatchRepository {
  final SkillRepository _skillRepository;
  final UserRepository _userRepository;
  final LocationService _locationService;

  MatchRepositoryImpl(
    this._skillRepository, 
    this._userRepository, 
    this._locationService, 
    {FirebaseDatabase? database}
  ) : super(database: database);

  @override
  Future<List<MatchModel>> generateMatches(String userId) async {
    // 1. Get current user
    final currentUser = await _userRepository.getUser(userId);
    if (currentUser == null) return [];

    // 2. Get all offered skills from other users
    final allOffers = await _skillRepository.searchSkills(""); 
    final externalOffers = allOffers.where((s) => s.ownerId != userId && s.type == 'offer').toList();

    List<MatchModel> matches = [];

    // 3. Compare desired skills with offers
    for (var desired in currentUser.desiredSkills) {
      for (var offer in externalOffers) {
        if (offer.name.toLowerCase() == desired.name.toLowerCase()) {
          // Fetch teacher details for ranking
          final teacher = await _userRepository.getUser(offer.ownerId!);
          if (teacher == null) continue;

          // Found a match!
          matches.add(MatchModel(
            id: "${userId}_${offer.ownerId}_${offer.id}",
            teacherUid: offer.ownerId!,
            learnerUid: userId,
            skillName: offer.name,
            confidenceScore: _calculateConfidence(currentUser, desired, teacher, offer),
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    // 4. Fetch existing matches to preserve statuses (accepted/declined/ignored)
    final existingMatches = await getMatches(userId);
    final Map<String, String> statusMap = { for (var m in existingMatches) m.id : m.status };

    // 5. Sort by confidence score
    matches.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

    // 6. Persist matches with preserved status
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      if (statusMap.containsKey(match.id)) {
        matches[i] = match.copyWith(status: statusMap[match.id]);
      }
      await setData(path: 'matches/${matches[i].id}', data: matches[i].toJson());
    }

    return matches;
  }

  @override
  Future<List<MatchModel>> getMatches(String userId) async {
    try {
      final snapshot = await getRef('matches')
          .orderByChild('learnerUid')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) return [];

      final Map<dynamic, dynamic> matchesMap = snapshot.value as Map<dynamic, dynamic>;
      return matchesMap.values
          .map((value) => MatchModel.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    } catch (e) {
      throw DatabaseException("Failed to fetch matches: ${e.toString()}", "fetch-matches-error");
    }
  }
  
  @override
  Future<void> updateMatchStatus(String matchId, String status) async {
    try {
      await updateData(path: 'matches/$matchId', data: {'status': status});
    } catch (e) {
      throw DatabaseException("Failed to update match status: ${e.toString()}", "update-match-error");
    }
  }


  double _calculateConfidence(UserModel learner, SkillModel desired, UserModel teacher, SkillModel offer) {
    double score = 0.0;

    // 1. Level Alignment (50%)
    // Ideal: Teacher is at least one level above learner
    final levels = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
    int learnerIdx = levels.indexOf(desired.level);
    int teacherIdx = levels.indexOf(offer.level);

    if (teacherIdx > learnerIdx) {
      score += 0.5; // Strong alignment
    } else if (teacherIdx == learnerIdx) {
      score += 0.3; // Equal levels
    } else {
      score += 0.1; // Teacher is lower level than learner (less ideal)
    }

    // 2. Proximity (30%)
    if (learner.location != null && teacher.location != null) {
      // Use Geolocator for valid distance calculations (M04)
      final distanceKm = _locationService.calculateDistance(learner.location!, teacher.location!);
      
      if (distanceKm < 10.0) {
        score += 0.3; // Local match bonus
      } else if (distanceKm < 50.0) {
        score += 0.15; // Regional match
      } else {
        score += 0.05; // distant but still reachable
      }
    }

    // 3. Profile Completeness (20%)
    if (teacher.photoUrl != null) score += 0.1;
    if (teacher.bio != null && teacher.bio!.isNotEmpty) score += 0.1;

    return score;
  }
}
