
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

// A service class to encapsulate all Firebase chat-related operations.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get a stream of messages for a specific chat.
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
      } catch (e) {
        debugPrint('Error parsing messages: $e');
        return []; // Return an empty list on parsing error
      }
    });
  }

  // Get a stream of the entire conversation document for real-time updates (e.g., typing status).
  Stream<DocumentSnapshot> getConversationStream(String chatId) {
    return _firestore.collection('conversations').doc(chatId).snapshots();
  }

  // Fetches a single, non-real-time snapshot of the conversation document.
  Future<DocumentSnapshot> getConversationDocument(String chatId) {
    return _firestore.collection('conversations').doc(chatId).get();
  }

  // Retrieves a user's display name from their user ID.
  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>).containsKey('email')) {
        return userDoc.get('email');
      } else {
        return "Chat User"; // Return a fallback name if email is not available
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
      return "Chat User"; // Return a fallback name on error
    }
  }

  // Sends a new message and updates the conversation's lastMessage field.
  Future<void> sendMessage(String chatId, String content) async {
    if (content.trim().isEmpty) return; // Don't send empty messages

    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    final message = Message(
      senderId: currentUserId,
      content: content,
      timestamp: timestamp,
    );

    // Add the new message to the 'messages' subcollection.
    await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Atomically update the 'lastMessage' field on the parent conversation document.
    await _firestore.collection('conversations').doc(chatId).update({
      'lastMessage': {
        'content': content,
        'timestamp': timestamp,
        'senderId': currentUserId,
      }
    });
  }

  // Updates the typing status for the current user in a conversation.
  Future<void> updateTypingStatus(
      String chatId, String userId, bool isTyping) async {
    try {
      // Use dot notation to update a specific user's status in the map.
      await _firestore
          .collection('conversations')
          .doc(chatId)
          .update({'typingStatus.$userId': isTyping});
    } catch (e) {
      // This error can happen if the `typingStatus` map doesn't exist yet.
      // In that case, we create it.
      if (e is FirebaseException && e.code == 'not-found') {
        await _firestore
            .collection('conversations')
            .doc(chatId)
            .set({'typingStatus': {userId: isTyping}}, SetOptions(merge: true));
      } else {
        debugPrint("Error updating typing status: $e");
      }
    }
  }
}
