class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastTimestamp;

  ChatRoomModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp?.toIso8601String(),
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      lastMessage: json['lastMessage'],
      lastTimestamp: json['lastTimestamp'] != null 
          ? DateTime.parse(json['lastTimestamp'] as String)
          : null,
    );
  }
}

