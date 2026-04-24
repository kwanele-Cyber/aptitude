import 'package:flutter/material.dart';
import 'package:myapp/core/models/chat_models.dart';
import 'package:myapp/core/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatViewModel(this._chatRepository);

  ChatRoomModel? _currentRoom;
  ChatRoomModel? get currentRoom => _currentRoom;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<String?> initiateChat(String userA, String userB) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentRoom = await _chatRepository.getOrCreateChatRoom(userA, userB);
      notifyListeners();
      return _currentRoom?.id;
    } catch (e) {
      _error = "Failed to start chat.";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void subscribeToMessages(String roomId, String currentUserId) {
    _chatRepository.getMessages(roomId).listen((msgs) {
      _messages = msgs;
      notifyListeners();
      // Mark as read when new messages arrive and we are in the room
      _chatRepository.markMessagesAsRead(roomId, currentUserId);
    });
  }

  Future<void> sendMessage(String senderId, String text) async {
    if (_currentRoom == null || text.trim().isEmpty) return;

    final message = MessageModel(
      id: DateTime.now().toString(),
      senderId: senderId,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    try {
      await _chatRepository.sendMessage(_currentRoom!.id, message);
    } catch (e) {
      _error = "Failed to send message.";
      notifyListeners();
    }
  }
}
