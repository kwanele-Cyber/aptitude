import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get a stream of messages for a given chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // For each message, also update its read status if it wasn't sent by the current user
        if (doc.data()['senderId'] != _auth.currentUser!.uid) {
          updateMessageReadStatus(chatId, doc.id);
        }
        return Message.fromMap(doc.data());
      }).toList();
    });
  }

  // Send a new text message
  Future<void> sendMessage(String chatId, String content) async {
    final currentUser = _auth.currentUser!;
    final newMessage = Message(
      senderId: currentUser.uid,
      content: content,
      timestamp: Timestamp.now(),
    );
    await _addMessageToChat(chatId, newMessage);
  }

  // Send an image message
  Future<void> sendImageMessage(String chatId, File imageFile) async {
    final currentUser = _auth.currentUser!;
    final timestamp = Timestamp.now();
    final String fileName = '${timestamp.millisecondsSinceEpoch}_${currentUser.uid}';

    // Upload the image to Firebase Storage
    final UploadTask uploadTask = _storage.ref('chat_images/$chatId/$fileName').putFile(imageFile);
    final TaskSnapshot storageSnap = await uploadTask;
    final String downloadUrl = await storageSnap.ref.getDownloadURL();

    final newMessage = Message(
      senderId: currentUser.uid,
      content: 'sent an image', // Fallback content
      timestamp: timestamp,
      imageUrl: downloadUrl,
    );
    await _addMessageToChat(chatId, newMessage);
  }

  // Helper to add a message to the database and update the conversation
  Future<void> _addMessageToChat(String chatId, Message message) async {
    await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _firestore.collection('conversations').doc(chatId).update({
      'lastMessage': message.toMap(),
    });
  }

  // Mark a message as read
  Future<void> updateMessageReadStatus(String chatId, String messageId) async {
    await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  // Set the user's typing status
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    final docRef = _firestore.collection('conversations').doc(chatId);
    if (isTyping) {
      // Add the user to the 'typing' array if they are not already in it
      await docRef.update({
        'typing': FieldValue.arrayUnion([userId])
      });
    } else {
      // Remove the user from the 'typing' array
      await docRef.update({
        'typing': FieldValue.arrayRemove([userId])
      });
    }
  }

  // Get the conversation stream for typing indicators
  Stream<DocumentSnapshot> getConversationStream(String chatId) {
    return _firestore.collection('conversations').doc(chatId).snapshots();
  }
}
