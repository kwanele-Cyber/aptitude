import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

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
}
