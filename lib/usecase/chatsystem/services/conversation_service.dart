import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get all conversations for a specific user
  Stream<List<Conversation>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromFirestore(doc))
          .toList();
    });
  }

  // Creates a new conversation if one doesn't already exist between the participants.
  Future<String> createConversation(List<String> participantIds) async {
    // Ensure there are at least two participants for a conversation.
    if (participantIds.length < 2) {
      throw ArgumentError('A conversation requires at least two participants.');
    }

    // Sort participant IDs to ensure the query is consistent, regardless of user order.
    participantIds.sort();

    // Check if a conversation with these exact participants already exists.
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('participantIds', isEqualTo: participantIds)
        .limit(1)
        .get();

    // If a conversation already exists, return its ID.
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      // If no conversation exists, create a new one.
      final newConversation = await _firestore.collection('conversations').add({
        'type': participantIds.length > 2 ? 'group' : 'oneToOne',
        'participantIds': participantIds,
        'groupName': null, // Can be updated later for group chats
        'groupImageUrl': null, // Can be updated later for group chats
        'lastMessage': 'Conversation started',
        'lastMessageTimestamp': Timestamp.now(),
      });
      return newConversation.id;
    }
  }
}
