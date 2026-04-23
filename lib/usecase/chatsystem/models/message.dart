import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String content;
  final Timestamp timestamp;

  Message({required this.senderId, required this.content, required this.timestamp});

  // Factory constructor to create a Message from a Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method to convert a Message object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
