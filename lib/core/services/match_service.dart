import 'package:myapp/core/data/models/match_result.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/services/match_engine.dart';

class MatchService {
  final UserRepository _userRepo;
  final UserSkillsRepository _skillsRepo;
  final MatchEngine _engine;

  MatchService({
    UserRepository? userRepo,
    UserSkillsRepository? skillsRepo,
    MatchEngine? engine,
  })  : _userRepo = userRepo ?? UserRepository(),
        _skillsRepo = skillsRepo ?? UserSkillsRepository(),
        _engine = engine ?? MatchEngine();

  /// Fetches and ranks all potential matches for a given user.
  Future<List<MatchResult>> getRankedMatches(String uid) async {
    // 1. Get current user's skills
    final myOffers = await _skillsRepo.getUserOffers(uid);
    final myRequests = await _skillsRepo.getUserRequests(uid);

    if (myOffers.isEmpty && myRequests.isEmpty) return [];

    // 2. Get all other users
    final allUsers = await _userRepo.listAll();
    final candidates = allUsers.where((u) => u.uid != uid).toList();

    List<MatchResult> results = [];

    // 3. Score each candidate
    for (var peer in candidates) {
      final peerOffers = await _skillsRepo.getUserOffers(peer.uid);
      final peerRequests = await _skillsRepo.getUserRequests(peer.uid);

      int bestScore = 0;
      // Temporary storage for tracking logic

      // Iterate through my requests vs their offers (They can teach me)
      for (var myReq in myRequests) {
        for (var peerOff in peerOffers) {
          if (myReq.sid == peerOff.sid) {
            // Check for reciprocal bonus
            int score = 0;
            bool foundReciprocal = false;

            for (var myOff in myOffers) {
              for (var peerReq in peerRequests) {
                if (myOff.sid == peerReq.sid) {
                  // Reciprocal match found!
                  score = _engine.calculateReciprocalScore(
                    myRequest: myReq,
                    myOffer: myOff,
                    peerOffer: peerOff,
                    peerRequest: peerReq,
                  );
                  foundReciprocal = true;
                  break;
                }
              }
              if (foundReciprocal) break;
            }

            // If no reciprocal match, calculate one-way score
            if (!foundReciprocal) {
              score = _engine.calculateMatchScore(
                myRequest: myReq,
                peerOffer: peerOff,
              );
            }

            if (score > bestScore) bestScore = score;
          }
        }
      }

      // 4. Record the result if there's any match
      if (bestScore > 0) {
        // Collect specifically which skills matched for UI display
        final matchingPeersOffers = peerOffers.where((po) => myRequests.any((mr) => mr.sid == po.sid)).toList();
        final matchingMyOffers = myOffers.where((mo) => peerRequests.any((pr) => pr.sid == mo.sid)).toList();

        results.add(MatchResult(
          peer: peer,
          score: bestScore,
          matchingOffers: matchingPeersOffers,
          matchingRequests: matchingMyOffers.map((mo) {
             // Just need to satisfy the MatchResult type which expects SkillRequest for matchingRequests 
             // Wait, MatchResult should probably hold the Peer's requests that I satisfy.
             return peerRequests.firstWhere((pr) => pr.sid == mo.sid);
          }).toList(),
        ));
      }
    }

    // 5. Rank matches by score
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }
}
