import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/core/error/app_exception.dart';

class ChatRepository {
  final String _channelPath = "chat_channels";
  final String _messagePath = "chat_messages";
  late final DatabaseService<DataSnapshot> _databaseService;

  ChatRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  /// Generates a deterministic channel ID for two users.
  String getChannelId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  /// Creates a new chat channel if it doesn't exist.
  Future<void> createChannel(ChatChannel channel) async {
    await _databaseService.create(
      location: "$_channelPath/${channel.id}",
      data: channel.toJson(),
    );
  }

  /// Fetches a specific channel.
  Future<ChatChannel?> getChannel(String channelId) async {
    final snapshot = await _databaseService.read(location: "$_channelPath/$channelId");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      return ChatChannel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  /// Sends a message and updates the channel metadata.
  Future<void> sendMessage(String channelId, ChatMessage message) async {
    if (message.content.trim().isEmpty) {
      throw ChatException('Cannot send an empty message', ErrorCode.emptyMessage);
    }
    
    // Check if channel exists
    final channel = await getChannel(channelId);
    if (channel == null) {
      throw ChatException('Chat channel not found', ErrorCode.channelNotFound);
    }

    try {
      // 1. Save the message
      await _databaseService.create(
        location: "$_messagePath/$channelId/${message.id}",
        data: message.toJson(),
      );

      // 2. Update channel's last message info
      await _databaseService.update(
        location: "$_channelPath/$channelId",
        data: {
          'lastMessage': message.content,
          'lastMessageTimestamp': message.timestamp,
        },
      );
    } catch (e) {
      throw ChatException('Failed to send message', ErrorCode.databaseError, e);
    }
  }

  /// Returns a stream of messages for a specific channel.
  Stream<List<ChatMessage>> getMessagesStream(String channelId) {
    final query = FirebaseDatabase.instance.ref("$_messagePath/$channelId").orderByChild('timestamp');
    
    return query.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> map = snapshot.value as Map;
        final list = map.values
            .map((v) => ChatMessage.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList();
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return list;
      }
      return [];
    });
  }

  /// Lists all active channels for a specific user.
  Future<List<ChatChannel>> listUserChannels(String uid) async {
    final snapshot = await _databaseService.list(location: _channelPath);
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((v) => ChatChannel.fromJson(Map<String, dynamic>.from(v as Map)))
          .where((c) => c.participants.contains(uid))
          .toList();
    }
    return [];
  }

  /// Marks all messages from the peer as read.
  Future<void> markMessagesAsRead(String channelId, String myUid) async {
    final ref = FirebaseDatabase.instance.ref("$_messagePath/$channelId");
    final snapshot = await ref.get();
    
    if (snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> messages = snapshot.value as Map;
      final updates = <String, dynamic>{};
      
      messages.forEach((key, value) {
        final msgMap = Map<String, dynamic>.from(value as Map);
        if (msgMap['senderId'] != myUid && (msgMap['isRead'] == false || msgMap['isRead'] == null)) {
          updates["$key/isRead"] = true;
        }
      });
      
      if (updates.isNotEmpty) {
        await ref.update(updates);
      }
    }
  }

  /// Sets the typing status for a user in a channel.
  Future<void> setTypingStatus(String channelId, String uid, bool isTyping) async {
    await FirebaseDatabase.instance.ref("typing/$channelId/$uid").set(isTyping);
  }

  /// Returns a stream of typing statuses for a specific channel.
  Stream<Map<String, bool>> streamTypingStatus(String channelId) {
    return FirebaseDatabase.instance.ref("typing/$channelId").onValue.map((event) {
      if (event.snapshot.value == null) return {};
      final Map<dynamic, dynamic> map = event.snapshot.value as Map;
      return map.map((key, value) => MapEntry(key.toString(), value as bool));
    });
  }
}
