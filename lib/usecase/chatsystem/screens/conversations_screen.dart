import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ConversationsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, userSnapshot) {
          // Show a loading spinner while waiting for auth state
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there is no user, something is wrong with the anonymous sign-in.
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Could not authenticate user. Please restart the app.'));
          }

          // Once we have the user, build the conversations list.
          final user = userSnapshot.data!;
          return _buildConversationsList(context, user);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.go('/new-conversation'),
      ),
    );
  }

  Widget _buildConversationsList(BuildContext context, User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('conversations')
          .where('members', arrayContains: user.uid)
          .orderBy('lastMessage.timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(child: Text('Something went wrong. Please restart the app.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No conversations yet.\nTap the '+' button to start one!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final conversations = snapshot.data!.docs;

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            var conversation = conversations[index];
            var lastMessage = conversation['lastMessage'] ?? {};

            return FutureBuilder<String>(
              future: _getPeerName(conversation['members'], user.uid),
              builder: (context, peerNameSnapshot) {
                final peerName = peerNameSnapshot.data ?? "Loading...";

                return ListTile(
                  leading: CircleAvatar(child: Text(peerName.isNotEmpty ? peerName[0].toUpperCase() : '?')),
                  title: Text(peerName),
                  subtitle: Text(lastMessage['content'] ?? 'No messages yet'),
                  trailing: Text(lastMessage['timestamp'] != null
                      ? (lastMessage['timestamp'] as Timestamp).toDate().toString().substring(10, 16)
                      : ''),
                  onTap: () => context.go('/chat/${conversation.id}'),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String> _getPeerName(List<dynamic> members, String currentUserId) async {
    final String peerId = members.firstWhere((id) => id != currentUserId, orElse: () => '');

    if (peerId.isEmpty) return "Unknown User";

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(peerId).get();
      if (userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('email')) {
        return userDoc.get('email');
      } else {
        return "Chat User"; // Fallback name for anonymous or incomplete user docs
      }
    } catch (e) {
      print("Error fetching peer name: $e");
      return "Chat User"; // Return a default name on error
    }
  }
}
