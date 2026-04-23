import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final List<String> participants;

  Conversation({
    required this.id,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.participants,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }
}
