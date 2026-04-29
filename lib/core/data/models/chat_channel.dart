class ChatChannel {
  final String id;
  final List<String> participants; // [uid1, uid2]
  final String lastMessage;
  final int lastMessageTimestamp;
  final Map<String, int> unreadCount; // {uid: count}
  final List<String> commonSkills;

  ChatChannel({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTimestamp = 0,
    this.unreadCount = const {},
    this.commonSkills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'unreadCount': unreadCount,
      'commonSkills': commonSkills,
    };
  }

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    return ChatChannel(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] as List),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'] as int? ?? 0,
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map? ?? {}),
      commonSkills: List<String>.from(json['commonSkills'] as List? ?? []),
    );
  }
}
