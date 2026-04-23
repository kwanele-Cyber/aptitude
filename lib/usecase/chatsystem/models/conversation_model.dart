import 'package:cloud_firestore/cloud_firestore.dart';

enum ConversationType {
  oneToOne,
  group,
}

class Conversation {
  final String id; // The document ID in Firestore
  final ConversationType type;
  final List<String> participantIds; // UIDs of users in the conversation
  final String? groupName; // Null if it's a 1-on-1 chat
  final String? groupImageUrl; // Null if it's a 1-on-1 chat
  final String lastMessage;
  final Timestamp lastMessageTimestamp;

  Conversation({
    required this.id,
    required this.type,
    required this.participantIds,
    this.groupName,
    this.groupImageUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  // Factory constructor to create a Conversation from a Firestore document
  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      type: data['type'] == 'group' ? ConversationType.group : ConversationType.oneToOne,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      groupName: data['groupName'],
      groupImageUrl: data['groupImageUrl'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
    );
  }
}
