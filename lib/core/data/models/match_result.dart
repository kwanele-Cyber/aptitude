import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';

class MatchResult {
  final User peer;
  final int score;
  final List<SkillOffer> matchingOffers; // Skills they have that I want
  final List<SkillRequest> matchingRequests; // Skills I have that they want

  MatchResult({
    required this.peer,
    required this.score,
    required this.matchingOffers,
    required this.matchingRequests,
  });

  bool get isReciprocal => matchingOffers.isNotEmpty && matchingRequests.isNotEmpty;
}
