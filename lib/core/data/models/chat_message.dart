enum MessageType { text, image, location, agreement }

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final int timestamp;
  final MessageType type;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'type': type.index,
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      type: MessageType.values[json['type'] as int? ?? 0],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
