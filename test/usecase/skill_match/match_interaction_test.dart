import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:myapp/core/data/models/match_result.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/match_repository.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/block_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/services/match_service.dart';
import 'package:myapp/usecase/skill_match/view_model/matches_view_model.dart';

import 'match_interaction_test.mocks.dart';

@GenerateMocks([AuthService, MatchService, BlockRepository, MatchRepository, ChatRepository])
void main() {
  late MatchesViewModel viewModel;
  late MockAuthService mockAuth;
  late MockMatchService mockMatchService;
  late MockBlockRepository mockBlockRepo;
  late MockMatchRepository mockMatchRepo;
  late MockChatRepository mockChatRepo;

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

  final testMatchResult = MatchResult(
    peer: peerUser,
    score: 80,
    matchingOffers: [],
    matchingRequests: [],
  );

  setUp(() {
    mockAuth = MockAuthService();
    mockMatchService = MockMatchService();
    mockBlockRepo = MockBlockRepository();
    mockMatchRepo = MockMatchRepository();
    mockChatRepo = MockChatRepository();

    viewModel = MatchesViewModel(
      authService: mockAuth,
      matchService: mockMatchService,
      blockRepo: mockBlockRepo,
      matchRepo: mockMatchRepo,
      chatRepo: mockChatRepo,
    );

    when(mockAuth.getCurrentUser()).thenAnswer((_) async => testUser);
  });

  group('Match Interaction Tests (M07-M11)', () {
    test('M07: acceptMatch should update repository and create chat channel', () async {
      when(mockMatchRepo.acceptMatch(any, any)).thenAnswer((_) async => {});
      when(mockChatRepo.getChannelId(any, any)).thenReturn('user1_peer1');
      when(mockChatRepo.getChannel(any)).thenAnswer((_) async => null);
      when(mockChatRepo.createChannel(any)).thenAnswer((_) async => {});

      await viewModel.acceptMatch(testMatchResult);

      verify(mockMatchRepo.acceptMatch('user1', 'peer1')).called(1);
      verify(mockChatRepo.createChannel(any)).called(1);
    });

    test('M08: rejectMatch should update repository to rejected status', () async {
      when(mockMatchRepo.rejectMatch(any, any)).thenAnswer((_) async => {});

      await viewModel.rejectMatch(testMatchResult);

      verify(mockMatchRepo.rejectMatch('user1', 'peer1')).called(1);
    });

    test('M09: ignoreMatch should update repository to ignored status', () async {
      when(mockMatchRepo.ignoreMatch(any, any)).thenAnswer((_) async => {});

      await viewModel.ignoreMatch(testMatchResult);

      verify(mockMatchRepo.ignoreMatch('user1', 'peer1')).called(1);
    });

    test('M11: saveMatch should update repository to saved status', () async {
      when(mockMatchRepo.saveMatch(any, any)).thenAnswer((_) async => {});

      await viewModel.saveMatch(testMatchResult);

      verify(mockMatchRepo.saveMatch('user1', 'peer1')).called(1);
    });
  });

  group('Match Filtering Tests (M10)', () {
     test('setMinTrustScore should trigger reload with filter', () async {
       when(mockMatchService.getRankedMatches(any)).thenAnswer((_) async => [testMatchResult]);
       when(mockBlockRepo.getBlockedList(any)).thenAnswer((_) async => []);

       await viewModel.setMinTrustScore(4.0);
       
       expect(viewModel.minTrustScore, 4.0);
       verify(mockMatchService.getRankedMatches('user1')).called(1);
     });
  });
}
