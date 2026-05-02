import '../data/models/skill_offer.dart';
import '../data/models/skill_request.dart';
import '../data/models/user.dart';
import 'dart:math' as math;

class MatchEngine {
  /// Base score for a skill ID match
  static const int baseMatchScore = 50;
  
  /// Bonus for reciprocal exchange (You have what I want, I have what you want)
  static const int reciprocalBonus = 100;
  static const int maxDistanceKm = 100;

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

    // Format compatibility bonus (M05)
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

  /// Adds geo proximity bonus based on Haversine distance (M04)
  int calculateGeoProximityBonus({required User me, required User peer}) {
    final hasCoordinates = me.location.latitude != 0.0 &&
        me.location.longitude != 0.0 &&
        peer.location.latitude != 0.0 &&
        peer.location.longitude != 0.0;
    if (!hasCoordinates) return 0;

    final distanceKm = _haversineKm(
      me.location.latitude,
      me.location.longitude,
      peer.location.latitude,
      peer.location.longitude,
    );

    if (distanceKm > maxDistanceKm) return 0;
    final normalized = 1 - (distanceKm / maxDistanceKm);
    return (normalized * 20).round();
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a.toDouble()), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);
}
