import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/services/match_service.dart';
import 'package:myapp/core/services/match_engine.dart';

// Manual Mocks
class MockUserRepo extends Fake implements UserRepository {
  List<User> users = [];
  @override
  Future<List<User>> listAll() async => users;
}

class MockSkillsRepo extends Fake implements UserSkillsRepository {
  Map<String, List<SkillOffer>> offers = {};
  Map<String, List<SkillRequest>> requests = {};

  @override
  Future<List<SkillOffer>> getUserOffers(String uid) async => offers[uid] ?? [];
  @override
  Future<List<SkillRequest>> getUserRequests(String uid) async => requests[uid] ?? [];
}

void main() {
  late MatchService matchService;
  late MockUserRepo mockUserRepo;
  late MockSkillsRepo mockSkillsRepo;

  setUp(() {
    mockUserRepo = MockUserRepo();
    mockSkillsRepo = MockSkillsRepo();
    matchService = MatchService(
      userRepo: mockUserRepo,
      skillsRepo: mockSkillsRepo,
      engine: MatchEngine(),
    );
  });

  User createUser(String id) {
    return User(
      uid: id,
      email: '$id@test.com',
      firstName: id,
      lastName: 'User',
      title: 'Dev',
      photoURL: '',
      skills: [],
      interests: [],
      bio: '',
      location: AddressModel.empty(),
      profileComplete: true,
      createdAt: DateTime.now(),
    );
  }

  group('MatchService Discovery Tests', () {
    test('Should prioritize reciprocal matches (Swaps)', () async {
      // 1. Current User (Me)
      final myId = 'me';
      mockSkillsRepo.requests[myId] = [
        SkillRequest(uid: myId, sid: 'flutter', skillName: 'Flutter', targetLevel: SkillLevel.intermediate, preferredFormat: SkillFormat.online, description: 'Learn')
      ];
      mockSkillsRepo.offers[myId] = [
        SkillOffer(uid: myId, sid: 'python', skillName: 'Python', level: SkillLevel.expert, format: SkillFormat.online, description: 'Teach')
      ];

      // 2. Peer A: Reciprocal (Has Flutter, Wants Python)
      final peerA = createUser('peerA');
      mockSkillsRepo.offers[peerA.uid] = [
        SkillOffer(uid: peerA.uid, sid: 'flutter', skillName: 'Flutter', level: SkillLevel.expert, format: SkillFormat.online, description: 'Teach')
      ];
      mockSkillsRepo.requests[peerA.uid] = [
        SkillRequest(uid: peerA.uid, sid: 'python', skillName: 'Python', targetLevel: SkillLevel.intermediate, preferredFormat: SkillFormat.online, description: 'Learn')
      ];

      // 3. Peer B: One-way (Has Flutter, Wants Yoga)
      final peerB = createUser('peerB');
      mockSkillsRepo.offers[peerB.uid] = [
        SkillOffer(uid: peerB.uid, sid: 'flutter', skillName: 'Flutter', level: SkillLevel.expert, format: SkillFormat.online, description: 'Teach')
      ];
      mockSkillsRepo.requests[peerB.uid] = [
        SkillRequest(uid: peerB.uid, sid: 'yoga', skillName: 'Yoga', targetLevel: SkillLevel.intermediate, preferredFormat: SkillFormat.online, description: 'Learn')
      ];

      mockUserRepo.users = [peerA, peerB];

      final results = await matchService.getRankedMatches(myId);

      expect(results.length, 2);
      expect(results[0].peer.uid, 'peerA'); // Reciprocal should be #1
      expect(results[0].score > results[1].score, true);
      expect(results[0].isReciprocal, true);
      expect(results[1].isReciprocal, false);
    });

    test('Should return empty list if no matches found', () async {
      final myId = 'me';
      mockSkillsRepo.requests[myId] = [
        SkillRequest(uid: myId, sid: 'swimming', skillName: 'Swimming', targetLevel: SkillLevel.intermediate, preferredFormat: SkillFormat.online, description: 'Learn')
      ];

      final peer = createUser('peer');
      mockSkillsRepo.offers[peer.uid] = [
        SkillOffer(uid: peer.uid, sid: 'dancing', skillName: 'Dancing', level: SkillLevel.expert, format: SkillFormat.online, description: 'Teach')
      ];

      mockUserRepo.users = [peer];

      final results = await matchService.getRankedMatches(myId);
      expect(results, isEmpty);
    });
  });
}
