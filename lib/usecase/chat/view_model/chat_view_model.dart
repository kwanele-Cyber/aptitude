import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final String channelId;
  final ChatRepository _chatRepo;
  final AgreementRepository _agreementRepo;
  final AuthService _auth;

  ChatViewModel({
    required this.channelId,
    ChatRepository? chatRepo,
    AgreementRepository? agreementRepo,
    AuthService? auth,
  })  : _chatRepo = chatRepo ?? ChatRepository(),
        _agreementRepo = agreementRepo ?? AgreementRepository(),
        _auth = auth ?? AuthService();

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _myUid;
  String? get myUid => _myUid;

  bool _peerIsTyping = false;
  bool get peerIsTyping => _peerIsTyping;

  Timer? _typingTimer;
  StreamSubscription? _typingSub;

  Future<void> init() async {
    final user = await _auth.getCurrentUser();
    if (user != null) {
      _myUid = user.uid;
    }

    _chatRepo.getMessagesStream(channelId).listen((newMessages) {
      _messages = newMessages;
      _isLoading = false;
      notifyListeners();
      
      // If we receive new messages while in the chat, mark them as read
      if (_myUid != null) {
        _chatRepo.markMessagesAsRead(channelId, _myUid!);
      }
    });
    
    if (_myUid != null) {
      _typingSub = _chatRepo.streamTypingStatus(channelId).listen((statusMap) {
        final peerTyping = statusMap.entries
            .any((e) => e.key != _myUid && e.value == true);
        
        if (_peerIsTyping != peerTyping) {
          _peerIsTyping = peerTyping;
          notifyListeners();
        }
      });
    }
  }

  Future<void> proposeAgreement(Agreement agreement) async {
    if (_myUid == null) return;

    // 1. Save agreement
    await _agreementRepo.createAgreement(agreement);

    // 2. Send message
    final message = ChatMessage(
      id: const Uuid().v4(),
      senderId: _myUid!,
      content: 'I proposed a skill swap agreement. Please review it!',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: MessageType.agreement,
      metadata: {'agreementId': agreement.id},
    );

    await _chatRepo.sendMessage(channelId, message);
  }

  Future<void> respondToAgreement(String agreementId, AgreementStatus status) async {
    await _agreementRepo.updateStatus(agreementId, status);
    
    final message = ChatMessage(
      id: const Uuid().v4(),
      senderId: _myUid!,
      content: 'I ${status.name} the agreement proposal.',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _chatRepo.sendMessage(channelId, message);
  }

  Future<void> sendMessage(String content) async {
    if (_myUid == null || content.trim().isEmpty) return;
    
    _errorMessage = null;
    notifyListeners();

    try {
      final message = ChatMessage(
        id: const Uuid().v4(),
        senderId: _myUid!,
        content: content.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _chatRepo.sendMessage(channelId, message);
    } on ChatException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
    }
  }

  void updateTypingStatus(bool isTyping) {
    if (_myUid == null) return;

    if (isTyping) {
      _chatRepo.setTypingStatus(channelId, _myUid!, true);
      
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _chatRepo.setTypingStatus(channelId, _myUid!, false);
      });
    } else {
      _typingTimer?.cancel();
      _chatRepo.setTypingStatus(channelId, _myUid!, false);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _typingSub?.cancel();
    if (_myUid != null) {
      _chatRepo.setTypingStatus(channelId, _myUid!, false);
    }
    super.dispose();
  }
}
