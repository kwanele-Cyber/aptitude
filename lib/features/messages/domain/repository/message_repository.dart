import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/domain/entity/inbox_conversation_entity.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';

abstract class MessageRepository {
  Future<Either<Failure, void>> sendMessage(MessageEntity message);
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String userId1, String userId2);
  Future<Either<Failure, void>> markMessagesAsRead(String userId1, String userId2);
  Stream<Either<Failure, List<InboxConversationEntity>>> watchInbox(String userId);
  Future<Either<Failure, String>> createRoom(RoomEntity room);
  Future<Either<Failure, void>> sendRoomMessage(String roomId, MessageEntity message);
  Stream<Either<Failure, List<MessageEntity>>> getRoomMessages(String roomId);
  
  // New features
  Future<Either<Failure, void>> addMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  });
  
  Future<Either<Failure, void>> removeMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  });
  
  Future<Either<Failure, void>> editMessage({
    required String messageId,
    required String newContent,
    required String roomId,
  });
  
  Future<Either<Failure, void>> setTypingIndicator({
    required String conversationId,
    required String userId,
    required bool isTyping,
  });
  
  Stream<Either<Failure, Map<String, bool>>> watchTypingIndicator({
    required String conversationId,
  });
}
