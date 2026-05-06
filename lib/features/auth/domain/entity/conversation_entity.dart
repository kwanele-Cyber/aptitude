

class ConversationEntity {
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationEntity({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  ConversationEntity copyWith({
    String? userId,
    String? userName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ConversationEntity(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ConversationService {
  static final Map<String, ConversationEntity> _conversations = {};

  static List<ConversationEntity> getConversations() {
    return _conversations.values.toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  static void addOrUpdateConversation(String userId, String userName, String message) {
    final now = DateTime.now();
    if (_conversations.containsKey(userId)) {
      _conversations[userId] = _conversations[userId]!.copyWith(
        lastMessage: message,
        lastMessageTime: now,
      );
    } else {
      _conversations[userId] = ConversationEntity(
        userId: userId,
        userName: userName,
        lastMessage: message,
        lastMessageTime: now,
      );
    }
  }

  static bool hasConversation(String userId) {
    return _conversations.containsKey(userId);
  }

  static void markAsRead(String userId) {
    if (_conversations.containsKey(userId)) {
      _conversations[userId] = _conversations[userId]!.copyWith(unreadCount: 0);
    }
  }
}