import '../data/models/skill_offer.dart';
import '../data/models/skill_request.dart';

class MatchEngine {
  /// Base score for a skill ID match
  static const int baseMatchScore = 50;
  
  /// Bonus for reciprocal exchange (You have what I want, I have what you want)
  static const int reciprocalBonus = 100;

  /// Calculates a score for a one-way match
  int calculateMatchScore({
    required SkillRequest myRequest,
    required SkillOffer peerOffer,
  }) {
    if (myRequest.sid != peerOffer.sid) return 0;

    int score = baseMatchScore;

    // Level compatibility bonus (M06)
    // If teacher is at or above target level, bonus
    if (peerOffer.level.index >= myRequest.targetLevel.index) {
      score += 20;
    }

    // Format compatibility bonus (M05 - partial)
    if (peerOffer.format == myRequest.preferredFormat) {
      score += 10;
    }

    return score;
  }

  /// Calculates a score for a full reciprocal swap (M02)
  int calculateReciprocalScore({
    required SkillRequest myRequest,
    required SkillOffer myOffer,
    required SkillOffer peerOffer,
    required SkillRequest peerRequest,
  }) {
    int score = 0;

    // Check if peer has what I want
    final myNeedMet = calculateMatchScore(myRequest: myRequest, peerOffer: peerOffer);
    if (myNeedMet == 0) return 0;

    // Check if I have what peer wants
    final peerNeedMet = calculateMatchScore(myRequest: peerRequest, peerOffer: myOffer);
    if (peerNeedMet == 0) return myNeedMet; // Still a one-way match

    // If both met, it's a reciprocal match!
    score = myNeedMet + peerNeedMet + reciprocalBonus;

    return score;
  }
}
