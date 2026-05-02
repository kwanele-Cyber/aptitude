import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/usecase/chat/view_model/chat_view_model.dart';
import 'dart:async';

@GenerateMocks([ChatRepository, AgreementRepository, AuthService])
import 'chat_view_model_test.mocks.dart';

void main() {
  late ChatViewModel viewModel;
  late MockChatRepository mockChatRepo;
  late MockAgreementRepository mockAgreementRepo;
  late MockAuthService mockAuthService;

  const channelId = 'test_channel';
  const myUid = 'user1';
  final testUser = User(
    uid: myUid,
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    title: 'Dev',
    photoURL: '',
    skills: [],
    interests: [],
    bio: '',
    location: AddressModel(address: "", latitude: 0.0, longitude: 0.0),
    createdAt: DateTime.now(),
    profileComplete: true,
  );

  setUp(() {
    mockChatRepo = MockChatRepository();
    mockAgreementRepo = MockAgreementRepository();
    mockAuthService = MockAuthService();

    // Default mock behaviors
    when(mockAuthService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockChatRepo.getMessagesStream(any)).thenAnswer((_) => Stream.value([]));
    when(mockChatRepo.streamTypingStatus(any)).thenAnswer((_) => Stream.value({}));
    
    viewModel = ChatViewModel(
      channelId: channelId,
      chatRepo: mockChatRepo,
      agreementRepo: mockAgreementRepo,
      auth: mockAuthService,
    );
  });

  group('ChatViewModel Tests', () {
    test('initially sets isLoading to true', () {
      expect(viewModel.isLoading, true);
    });

    test('init() fetches user and marks messages as read', () async {
      await viewModel.init();

      expect(viewModel.myUid, myUid);
      verify(mockChatRepo.markMessagesAsRead(channelId, myUid)).called(1);
    });

    test('sendMessage sets error message when ChatException occurs', () async {
      await viewModel.init();

      when(mockChatRepo.sendMessage(any, any))
          .thenThrow(ChatException('Empty message', ErrorCode.emptyMessage));

      await viewModel.sendMessage('   ');

      expect(viewModel.errorMessage, 'Empty message');
      verify(mockChatRepo.sendMessage(channelId, any)).called(1);
    });

    test('sendMessage handles generic exceptions', () async {
      await viewModel.init();

      when(mockChatRepo.sendMessage(any, any)).thenThrow(Exception('DB Fail'));

      await viewModel.sendMessage('Hello');

      expect(viewModel.errorMessage, 'An unexpected error occurred');
    });

    test('updateTypingStatus calls repository with debounce timer', () async {
      await viewModel.init();

      viewModel.updateTypingStatus(true);
      verify(mockChatRepo.setTypingStatus(channelId, myUid, true)).called(1);
    });

    test('disposes timer and listeners', () async {
      await viewModel.init();
      viewModel.dispose();
      
      verify(mockChatRepo.setTypingStatus(channelId, myUid, false)).called(1);
    });
  });
}
