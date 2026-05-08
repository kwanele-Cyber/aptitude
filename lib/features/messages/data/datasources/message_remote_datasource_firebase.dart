import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/messages/data/datasources/message_remote_datasource.dart';
import 'package:myapp/features/messages/data/models/message_model.dart';
import 'package:myapp/features/messages/domain/entity/inbox_conversation_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';

class MessageRemoteDataSourceFirebase implements MessageRemoteDataSource {
  final FirebaseDatabase _database;
  final Uuid _uuid = const Uuid();

  MessageRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _messagesRef => _database.ref('messages');

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      final chatId = _getChatId(message.senderId, message.receiverId);
      await _messagesRef.child(chatId).child(message.id).set(message.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String userId1, String userId2) {
    final chatId = _getChatId(userId1, userId2);
    final chatRef = _messagesRef.child(chatId);

    return chatRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = <MessageModel>[];

      data.forEach((key, value) {
        final messageData = Map<String, dynamic>.from(value as Map);
        messages.add(MessageModel.fromJson(key, messageData));
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  @override
  Future<void> markMessagesAsRead(String userId1, String userId2) async {
    try {
      final chatId = _getChatId(userId1, userId2);
      final chatRef = _messagesRef.child(chatId);

      final snapshot = await chatRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.value as Map<dynamic, dynamic>;
      final updates = <String, dynamic>{};

      data.forEach((key, value) {
        final messageData = Map<String, dynamic>.from(value as Map);
        final isUnread = !(messageData['isRead'] as bool? ?? false);
        if (messageData['receiverId'] == userId1 && isUnread) {
          updates['$key/isRead'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await chatRef.update(updates);
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<List<InboxConversationEntity>> watchInbox(String userId) {
    final rootRef = _database.ref();
    return rootRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return const <InboxConversationEntity>[];
      }

      final root = Map<String, dynamic>.from(event.snapshot.value as Map);
      final roomsRoot = root['rooms'];
      final messagesRoot = root['messages'];

      final rooms = <String, _RoomMetadata>{};
      if (roomsRoot is Map) {
        final roomsMap = Map<String, dynamic>.from(roomsRoot);
        roomsMap.forEach((roomId, roomValue) {
          if (roomValue is! Map) return;
          final memberIds = <String>[];
          final rawMemberIds = roomValue['memberIds'];
          if (rawMemberIds is List) {
            memberIds.addAll(rawMemberIds.cast<String>());
          }

          if (!memberIds.contains(userId)) return;

          rooms[roomId] = _RoomMetadata(
            id: roomId,
            name: roomValue['name'] as String? ?? 'Room',
            createdBy: roomValue['createdBy'] as String? ?? '',
            createdAt: DateTime.tryParse(roomValue['createdAt'] as String? ?? '') ?? DateTime.now(),
            memberIds: memberIds,
          );
        });
      }

      final directConversations = <String, _InboxAccumulator>{};
      final roomConversations = <String, _InboxAccumulator>{};

      if (messagesRoot is Map) {
        final rootMessagesMap = Map<String, dynamic>.from(messagesRoot);
        rootMessagesMap.forEach((_, chatValue) {
          if (chatValue is! Map) return;
          final messagesMap = Map<String, dynamic>.from(chatValue);

          for (final entry in messagesMap.entries) {
            if (entry.value is! Map) continue;
            final message = MessageModel.fromJson(
              entry.key,
              Map<String, dynamic>.from(entry.value as Map),
            );

            if (message.roomId != null) {
              final roomMeta = rooms[message.roomId!];
              if (roomMeta == null) continue;

              final existing = roomConversations[message.roomId!];
              if (existing == null || message.timestamp.isAfter(existing.lastMessageTime)) {
                roomConversations[message.roomId!] = _InboxAccumulator(
                  userId: message.roomId!,
                  title: roomMeta.name,
                  lastMessage: message.content,
                  lastMessageTime: message.timestamp,
                  lastSenderId: message.senderId,
                  unreadCount: existing == null
                      ? 0
                      : existing.unreadCount,
                );
              }
              continue;
            }

            if (message.senderId != userId && message.receiverId != userId) {
              continue;
            }

            final otherUserId =
                message.senderId == userId ? message.receiverId : message.senderId;
            final existing = directConversations[otherUserId];

            if (existing == null || message.timestamp.isAfter(existing.lastMessageTime)) {
              directConversations[otherUserId] = _InboxAccumulator(
                userId: otherUserId,
                lastMessage: message.content,
                lastMessageTime: message.timestamp,
                lastSenderId: message.senderId,
                unreadCount: (message.receiverId == userId && !message.isRead)
                    ? 1 + (existing?.unreadCount ?? 0)
                    : existing?.unreadCount ?? 0,
              );
            } else if (message.receiverId == userId && !message.isRead) {
              directConversations[otherUserId] = existing.copyWith(
                unreadCount: existing.unreadCount + 1,
              );
            }
          }
        });
      }

      for (final roomMeta in rooms.values) {
        final existing = roomConversations[roomMeta.id];
        if (existing == null) {
          roomConversations[roomMeta.id] = _InboxAccumulator(
            userId: roomMeta.id,
            title: roomMeta.name,
            lastMessage: 'You were added to the room "${roomMeta.name}".',
            lastMessageTime: roomMeta.createdAt,
            lastSenderId: roomMeta.createdBy,
            unreadCount: 0,
          );
        }
      }

      final inbox = <InboxConversationEntity>[];
      inbox.addAll(directConversations.values.map((conversation) => InboxConversationEntity(
            conversationId: conversation.userId,
            title: '',
            isRoom: false,
            lastMessage: conversation.lastMessage,
            lastMessageTime: conversation.lastMessageTime,
            lastSenderId: conversation.lastSenderId,
            unreadCount: conversation.unreadCount,
          )));
      inbox.addAll(roomConversations.values.map((conversation) => InboxConversationEntity(
            conversationId: conversation.userId,
            title: conversation.title ?? 'Room',
            isRoom: true,
            memberIds: rooms[conversation.userId]?.memberIds,
            createdBy: rooms[conversation.userId]?.createdBy,
            createdAt: rooms[conversation.userId]?.createdAt,
            lastMessage: conversation.lastMessage,
            lastMessageTime: conversation.lastMessageTime,
            lastSenderId: conversation.lastSenderId,
            unreadCount: conversation.unreadCount,
          )));

      inbox.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return inbox;
    });
  }

  @override
  Future<String> createRoom(RoomEntity room) async {
    try {
      final roomId = room.id.isEmpty ? _uuid.v4() : room.id;
      await _database.ref('rooms/$roomId').set({
        'id': roomId,
        'name': room.name,
        'createdBy': room.createdBy,
        'memberIds': room.memberIds,
        'createdAt': room.createdAt.toIso8601String(),
      });
      return roomId;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> sendRoomMessage(String roomId, MessageModel message) async {
    try {
      await _database
          .ref('rooms/$roomId/messages')
          .child(message.id)
          .set(message.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<List<MessageModel>> getRoomMessages(String roomId) {
    final chatRef = _database.ref('rooms/$roomId/messages');

    return chatRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final messages = <MessageModel>[];

      data.forEach((key, value) {
        final messageData = Map<String, dynamic>.from(value as Map);
        messages.add(MessageModel.fromJson(key, messageData));
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  @override
  Future<void> addMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final reactionId = _uuid.v4();
      await _database.ref('reactions/$messageId/$reactionId').set({
        'messageId': messageId,
        'userId': userId,
        'emoji': emoji,
        'addedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> removeMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final snapshot = await _database.ref('reactions/$messageId').get();
      if (!snapshot.exists) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (final entry in data.entries) {
        final reactionData = Map<String, dynamic>.from(entry.value as Map);
        if (reactionData['userId'] == userId && reactionData['emoji'] == emoji) {
          await _database.ref('reactions/$messageId/${entry.key}').remove();
          break;
        }
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> editMessage({
    required String messageId,
    required String newContent,
    required String roomId,
  }) async {
    try {
      final editedAt = DateTime.now().toIso8601String();
      await _database.ref('rooms/$roomId/messages/$messageId').update({
        'content': newContent,
        'editedAt': editedAt,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> setTypingIndicator({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      if (isTyping) {
        await _database
            .ref('typingIndicators/$conversationId/$userId')
            .set({'timestamp': DateTime.now().toIso8601String()});
      } else {
        await _database.ref('typingIndicators/$conversationId/$userId').remove();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<Map<String, bool>> watchTypingIndicator({
    required String conversationId,
  }) {
    final typingRef = _database.ref('typingIndicators/$conversationId');
    return typingRef.onValue.map((event) {
      final typingStatus = <String, bool>{};

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final now = DateTime.now();

        data.forEach((userId, value) {
          if (value is Map) {
            final timestamp =
                DateTime.tryParse(value['timestamp'] as String? ?? '') ?? now;
            final isRecent = now.difference(timestamp).inSeconds < 5;
            typingStatus[userId] = isRecent;
          }
        });
      }

      return typingStatus;
    });
  }

  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Future<void> blockUser(
      String currentUserId, String blockedUserId, String blockedUserName) async {
    try {
      await _database
          .ref('blockedUsers/$currentUserId/$blockedUserId')
          .set({
        'blockedAt': DateTime.now().toIso8601String(),
        'userName': blockedUserName,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> unblockUser(String currentUserId, String blockedUserId) async {
    try {
      await _database
          .ref('blockedUsers/$currentUserId/$blockedUserId')
          .remove();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<List<String>> getBlockedUserIds(String userId) {
    return _database.ref('blockedUsers/$userId').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.keys.toList();
    });
  }
}

class _InboxAccumulator {
  final String userId;
  final String? title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;
  final int unreadCount;

  const _InboxAccumulator({
    required this.userId,
    this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
    required this.unreadCount,
  });

  _InboxAccumulator copyWith({
    String? userId,
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastSenderId,
    int? unreadCount,
  }) {
    return _InboxAccumulator(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class _RoomMetadata {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;

  const _RoomMetadata({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
  });
}
