import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:myapp/core/data/models/agreement.dart';
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
    when(
      mockChatRepo.getMessagesStream(any),
    ).thenAnswer((_) => Stream.value([]));
    when(
      mockChatRepo.streamTypingStatus(any),
    ).thenAnswer((_) => Stream.value({}));
    when(mockChatRepo.sendMessage(any, any)).thenAnswer((_) async {});
    when(mockAgreementRepo.createAgreement(any)).thenAnswer((_) async {});
    when(mockAgreementRepo.updateStatus(any, any)).thenAnswer((_) async {});
    when(mockAgreementRepo.listByChannel(any)).thenAnswer((_) async => []);
    when(
      mockAgreementRepo.modifyAgreementTerms(
        id: anyNamed('id'),
        sessionsCount: anyNamed('sessionsCount'),
        minutesPerSession: anyNamed('minutesPerSession'),
        frequency: anyNamed('frequency'),
      ),
    ).thenAnswer((_) async {});

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
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.myUid, myUid);
      verify(mockChatRepo.markMessagesAsRead(channelId, myUid)).called(1);
    });

    test('sendMessage sets error message when ChatException occurs', () async {
      await viewModel.init();

      when(
        mockChatRepo.sendMessage(any, any),
      ).thenThrow(ChatException('Empty message', ErrorCode.emptyMessage));

      await viewModel.sendMessage('Hello');

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
      await Future<void>.delayed(Duration.zero);
      viewModel.dispose();

      verify(mockChatRepo.setTypingStatus(channelId, myUid, false)).called(1);
    });

    test(
      'proposeAgreement creates agreement and sends agreement message',
      () async {
        await viewModel.init();

        final agreement = Agreement(
          id: 'agreement_1',
          channelId: channelId,
          proposerId: myUid,
          receiverId: 'user2',
          offerSkillId: 'guitar',
          requestSkillId: 'spanish',
          sessionsCount: 4,
          minutesPerSession: 60,
          frequency: 'Weekly',
          createdAt: 1,
        );

        await viewModel.proposeAgreement(agreement);

        verify(mockAgreementRepo.createAgreement(agreement)).called(1);
        final captured =
            verify(
                  mockChatRepo.sendMessage(channelId, captureAny),
                ).captured.last
                as ChatMessage;
        expect(captured.type, MessageType.agreement);
        expect(captured.metadata?['agreementId'], 'agreement_1');
      },
    );

    test(
      'respondToAgreement accepts agreement and sends status message',
      () async {
        await viewModel.init();

        await viewModel.respondToAgreement(
          'agreement_1',
          AgreementStatus.accepted,
        );

        verify(
          mockAgreementRepo.updateStatus(
            'agreement_1',
            AgreementStatus.accepted,
          ),
        ).called(1);
        verify(mockChatRepo.sendMessage(channelId, any)).called(1);
      },
    );

    test(
      'modifyAgreement updates terms and resets proposal to pending',
      () async {
        await viewModel.init();

        await viewModel.modifyAgreement(
          agreementId: 'agreement_1',
          sessionsCount: 6,
          minutesPerSession: 45,
          frequency: 'Biweekly',
        );

        verify(
          mockAgreementRepo.modifyAgreementTerms(
            id: 'agreement_1',
            sessionsCount: 6,
            minutesPerSession: 45,
            frequency: 'Biweekly',
          ),
        ).called(1);
        verify(mockChatRepo.sendMessage(channelId, any)).called(1);
      },
    );

    test(
      'cancelAgreement marks agreement as cancelled and sends system message',
      () async {
        await viewModel.init();

        await viewModel.cancelAgreement('agreement_1');

        verify(
          mockAgreementRepo.updateStatus(
            'agreement_1',
            AgreementStatus.cancelled,
          ),
        ).called(1);
        final captured =
            verify(
                  mockChatRepo.sendMessage(channelId, captureAny),
                ).captured.last
                as ChatMessage;
        expect(captured.type, MessageType.text);
        expect(captured.metadata?['agreementId'], 'agreement_1');
      },
    );

    test(
      'getChannelAgreements lists agreements for the chat channel',
      () async {
        await viewModel.getChannelAgreements();

        verify(mockAgreementRepo.listByChannel(channelId)).called(1);
      },
    );
  });
}
