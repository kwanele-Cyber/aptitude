import 'package:equatable/equatable.dart';

class InboxConversationEntity extends Equatable {
  final String conversationId;
  final String title;
  final bool isRoom;
  final List<String>? memberIds;
  final String? createdBy;
  final DateTime? createdAt;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;
  final int unreadCount;

  const InboxConversationEntity({
    required this.conversationId,
    required this.title,
    this.isRoom = false,
    this.memberIds,
    this.createdBy,
    this.createdAt,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        conversationId,
        title,
        isRoom,
        memberIds,
        createdBy,
        createdAt,
        lastMessage,
        lastMessageTime,
        lastSenderId,
        unreadCount,
      ];
}
