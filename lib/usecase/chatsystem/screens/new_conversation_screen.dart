import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../services/conversation_service.dart';

class NewConversationScreen extends StatelessWidget {
  final ConversationService _conversationService = ConversationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NewConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Conversation')),
        body: const Center(child: Text('Please log in to start a new conversation.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Conversation'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where(FieldPath.documentId, isNotEqualTo: currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log('Error loading users: ', error: snapshot.error, stackTrace: snapshot.stackTrace);
            return const Center(child: Text('An error occurred. Please try again later.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No other users found to chat with."));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>? ?? {};
              final userName = userData['name']?.toString() ?? 'User';
              final profileImageUrl = userData['profileImageUrl']?.toString();

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty) ? NetworkImage(profileImageUrl) : null,
                  child: (profileImageUrl == null || profileImageUrl.isEmpty) && userName.isNotEmpty
                      ? Text(userName.substring(0, 1).toUpperCase())
                      : null,
                ),
                title: Text(userName),
                onTap: () async {
                  try {
                    final conversationId = await _conversationService.createConversation([currentUser.uid, userDoc.id]);
                    if (context.mounted) {
                      context.push('/chat/$conversationId');
                    }
                  } catch (e, s) {
                    log('Error creating conversation: ', error: e, stackTrace: s);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not create conversation. Please try again.')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
