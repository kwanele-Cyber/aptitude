import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:myapp/core/data/models/match.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/match_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/usecase/skill_match/view_model/match_history_view_model.dart';

import 'match_history_test.mocks.dart';

@GenerateMocks([AuthService, MatchRepository, UserRepository])
void main() {
  late MatchHistoryViewModel viewModel;
  late MockAuthService mockAuth;
  late MockMatchRepository mockMatchRepo;
  late MockUserRepository mockUserRepo;

  final testUser = User(
    uid: 'user1',
    email: 'test@test.com',
    firstName: 'Test',
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

  final peerUser = User(
    uid: 'peer1',
    email: 'peer@test.com',
    firstName: 'Peer',
    lastName: 'User',
    title: 'Designer',
    photoURL: '',
    skills: [],
    interests: [],
    bio: '',
    location: AddressModel.empty(),
    profileComplete: true,
    createdAt: DateTime.now(),
  );

  final testMatch = Match(
    id: 'match1',
    participants: ['user1', 'peer1'],
    status: MatchStatus.accepted,
    createdAt: DateTime.now(),
    lastActionBy: 'user1',
  );

  setUp(() {
    mockAuth = MockAuthService();
    mockMatchRepo = MockMatchRepository();
    mockUserRepo = MockUserRepository();

    viewModel = MatchHistoryViewModel(
      authService: mockAuth,
      matchRepo: mockMatchRepo,
      userRepo: mockUserRepo,
    );

    when(mockAuth.getCurrentUser()).thenAnswer((_) async => testUser);
  });

  group('Match History Tests (M12)', () {
    test('loadHistory should fetch matches and resolve peers', () async {
      when(mockMatchRepo.getUserMatches('user1')).thenAnswer((_) async => [testMatch]);
      when(mockUserRepo.read('peer1')).thenAnswer((_) async => peerUser);

      await viewModel.loadHistory();

      expect(viewModel.accepted.length, 1);
      expect(viewModel.accepted.first.peer.uid, 'peer1');
      verify(mockMatchRepo.getUserMatches('user1')).called(1);
      verify(mockUserRepo.read('peer1')).called(1);
    });

    test('updateStatus should trigger repository update and refresh', () async {
      when(mockMatchRepo.updateMatchStatus(any, any, any)).thenAnswer((_) async => {});
      when(mockMatchRepo.getUserMatches(any)).thenAnswer((_) async => []);

      await viewModel.updateStatus('match1', MatchStatus.rejected);

      verify(mockMatchRepo.updateMatchStatus('match1', MatchStatus.rejected, 'user1')).called(1);
      verify(mockMatchRepo.getUserMatches('user1')).called(1);
    });
  });
}
