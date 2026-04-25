import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> sendMessage(
      Message message, String chatId) async {
    return await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID to the Message object for later use
        return Message.fromMap(data..['id'] = doc.id);
      }).toList();
    });
  }

  Future<void> markAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<void> setTypingStatus(
      String chatId, String userId, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).set(
      {
        'typing': {
          userId: isTyping,
        }
      },
      SetOptions(merge: true),
    );
  }

  Stream<bool> getTypingStatusStream(String chatId, String otherUserId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('typing')) {
        final typing = snapshot.data()!['typing'] as Map<String, dynamic>;
        return typing[otherUserId] ?? false;
      }
      return false;
    });
  }

  Future<void> addReaction(
      String chatId, String messageId, String userId, String emoji) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': emoji,
    });
  }

  Future<void> removeReaction(
      String chatId, String messageId, String userId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': FieldValue.delete(),
    });
  }
}
