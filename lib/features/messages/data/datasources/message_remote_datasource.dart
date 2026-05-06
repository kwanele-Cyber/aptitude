import 'package:myapp/features/messages/data/models/message_model.dart';
import 'package:myapp/features/messages/domain/entity/inbox_conversation_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';

abstract class MessageRemoteDataSource {
  Future<void> sendMessage(MessageModel message);
  Stream<List<MessageModel>> getMessages(String userId1, String userId2);
  Future<void> markMessagesAsRead(String userId1, String userId2);
  Stream<List<InboxConversationEntity>> watchInbox(String userId);
  Future<String> createRoom(RoomEntity room);
  Future<void> sendRoomMessage(String roomId, MessageModel message);
  Stream<List<MessageModel>> getRoomMessages(String roomId);
  
  // New features
  Future<void> addMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  });
  
  Future<void> removeMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  });
  
  Future<void> editMessage({
    required String messageId,
    required String newContent,
    required String roomId,
  });
  
  Future<void> setTypingIndicator({
    required String conversationId,
    required String userId,
    required bool isTyping,
  });
  
  Stream<Map<String, bool>> watchTypingIndicator({
    required String conversationId,
  });
}
