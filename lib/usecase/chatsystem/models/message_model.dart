import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;
  final String? fileUrl;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.imageUrl,
    this.fileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      fileUrl: map['fileUrl'],
    );
  }
}


