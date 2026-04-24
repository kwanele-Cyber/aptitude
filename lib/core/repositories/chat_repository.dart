import 'package:myapp/core/models/chat_models.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class ChatRepository {
  Future<ChatRoomModel> getOrCreateChatRoom(String userA, String userB);
  Stream<List<MessageModel>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, MessageModel message);
  Future<void> markMessagesAsRead(String roomId, String userId);
}

class ChatRepositoryImpl extends BaseDatabaseService implements ChatRepository {
  ChatRepositoryImpl({FirebaseDatabase? database}) : super(database: database);
  @override
  Future<ChatRoomModel> getOrCreateChatRoom(String userA, String userB) async {
    try {
      // Sort IDs to ensure consistent room ID between same two users
      final ids = [userA, userB]..sort();
      final roomId = ids.join('_');

      final snapshot = await getRef('chats/$roomId').get();

      if (snapshot.exists) {
        return ChatRoomModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      } else {
        final newRoom = ChatRoomModel(
          id: roomId,
          participantIds: ids,
        );
        await setData(path: 'chats/$roomId', data: newRoom.toJson());
        return newRoom;
      }
    } catch (e) {
      throw DatabaseException("Failed to initiate chat room: ${e.toString()}", "chat-init-error");
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String roomId) {
    return dataStream('chats/$roomId/messages').map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return [];

      final Map<dynamic, dynamic> messagesMap = snapshot.value as Map<dynamic, dynamic>;
      final List<MessageModel> messages = messagesMap.values
          .map((value) => MessageModel.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();

      // Sort by timestamp descending
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  @override
  Future<void> sendMessage(String roomId, MessageModel message) async {
    try {
      final msgId = generateId('chats/$roomId/messages');
      final msgData = message.toJson();
      
      // Update room metadata and add message in one go using updateData with multiple paths
      final Map<String, dynamic> updates = {
        'chats/$roomId/messages/$msgId': msgData,
        'chats/$roomId/lastMessage': message.text,
        'chats/$roomId/lastTimestamp': message.timestamp.toIso8601String(),
      };
      
      await getRef('').update(updates);
    } catch (e) {
      throw DatabaseException("Failed to send message: ${e.toString()}", "msg-send-error");
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final snapshot = await getRef('chats/$roomId/messages')
          .get();

      if (!snapshot.exists) return;

      final Map<dynamic, dynamic> messagesMap = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> updates = {};

      messagesMap.forEach((key, value) {
        final data = Map<String, dynamic>.from(value as Map);
        if (data['senderId'] != userId && data['isRead'] == false) {
          updates['chats/$roomId/messages/$key/isRead'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await getRef('').update(updates);
      }
    } catch (e) {
      // Silent fail for status updates
    }
  }
}

