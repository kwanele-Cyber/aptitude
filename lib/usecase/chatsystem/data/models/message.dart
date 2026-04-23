import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String content;
  final Timestamp timestamp;
  final String? imageUrl; // Optional: for image messages
  final bool isRead;      // For read receipts

  Message({
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.isRead = false, // Default to unread
  });

  // Convert a Message object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'isRead': isRead,
    };
  }

  // Create a Message object from a Firestore document
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      imageUrl: map['imageUrl'],
      isRead: map['isRead'] ?? false,
    );
  }
}
