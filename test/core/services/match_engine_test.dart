import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/services/match_engine.dart'; // We will create this

void main() {
  late MatchEngine matchEngine;

  setUp(() {
    matchEngine = MatchEngine();
  });

  group('M01 & M02: Matchmaking Logic Tests', () {
    test('Should identify a direct match (Teacher has what Learner wants)', () {
      final myRequest = SkillRequest(
        uid: 'me',
        sid: 'flutter',
        skillName: 'Flutter',
        targetLevel: SkillLevel.intermediate,
        preferredFormat: SkillFormat.online,
        description: 'Learning Flutter',
      );

      final peerOffer = SkillOffer(
        uid: 'peer',
        sid: 'flutter',
        skillName: 'Flutter',
        level: SkillLevel.expert,
        format: SkillFormat.online,
        description: 'Teaching Flutter',
      );

      final score = matchEngine.calculateMatchScore(
        myRequest: myRequest,
        peerOffer: peerOffer,
      );

      expect(score, greaterThan(0), reason: 'A direct skill match should have a positive score');
    });

    test('Should prioritize Reciprocal Matches (M02: Scoring)', () {
      final myRequest = SkillRequest(
        uid: 'me',
        sid: 'flutter',
        skillName: 'Flutter',
        targetLevel: SkillLevel.intermediate,
        preferredFormat: SkillFormat.online,
        description: 'Need Flutter',
      );
      final myOffer = SkillOffer(
        uid: 'me',
        sid: 'design',
        skillName: 'Design',
        level: SkillLevel.expert,
        format: SkillFormat.online,
        description: 'Expert Design',
      );

      // Peer 1: Only teaches Flutter
      final peer1Offer = SkillOffer(
        uid: 'p1',
        sid: 'flutter',
        skillName: 'Flutter',
        level: SkillLevel.expert,
        format: SkillFormat.online,
        description: 'T1',
      );
      
      // Peer 2: Teaches Flutter AND wants Design (Perfect Swap)
      final peer2Offer = SkillOffer(
        uid: 'p2',
        sid: 'flutter',
        skillName: 'Flutter',
        level: SkillLevel.expert,
        format: SkillFormat.online,
        description: 'T2',
      );
      final peer2Request = SkillRequest(
        uid: 'p2',
        sid: 'design',
        skillName: 'Design',
        targetLevel: SkillLevel.beginner,
        preferredFormat: SkillFormat.online,
        description: 'R2',
      );

      final score1 = matchEngine.calculateMatchScore(
        myRequest: myRequest,
        peerOffer: peer1Offer,
      );

      final score2 = matchEngine.calculateReciprocalScore(
        myRequest: myRequest,
        myOffer: myOffer,
        peerOffer: peer2Offer,
        peerRequest: peer2Request,
      );

      expect(score2, greaterThan(score1), reason: 'Reciprocal matches should rank significantly higher than one-way matches');
    });
  });
}
