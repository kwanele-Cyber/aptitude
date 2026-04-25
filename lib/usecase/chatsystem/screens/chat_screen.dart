import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  String? _receiverId;
  String? _senderId;
  Future<DocumentSnapshot>? _receiverFuture;
  Stream<bool>? _typingStream;

  @override
  void initState() {
    super.initState();
    _senderId = FirebaseAuth.instance.currentUser?.uid;
    _receiverId = widget.chatId.replaceAll(_senderId!, '-').replaceAll('-', '');
    _receiverFuture =
        FirebaseFirestore.instance.collection('users').doc(_receiverId).get();
    _typingStream = _chatService.getTypingStatusStream(widget.chatId, _receiverId!);
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final names = name.trim().split(' ');
    String initials = names[0][0];
    if (names.length > 1) {
      initials += names.last[0];
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _receiverFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Text("Chat");
            }
            final receiverData = snapshot.data!.data() as Map<String, dynamic>;
            final receiverName = receiverData['name'] ?? 'Chat';
            final initials = _getInitials(receiverName);

            return Row(
              children: [
                CircleAvatar(
                  child: Text(initials),
                ),
                SizedBox(width: 12),
                Text(receiverName),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No messages yet. Say hi!"));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading messages."));
                }
                final messages = snapshot.data!;
                // Mark messages as read
                for (var message in messages) {
                  if (message.senderId != _senderId && !message.isRead) {
                    _chatService.markAsRead(widget.chatId, message.id!);
                  }
                }
                return ListView.builder(
                  reverse: true, // Show latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      onReaction: (messageId, userId, emoji, chatId) {
                        _chatService.addReaction(
                            widget.chatId, messageId, userId, emoji);
                      },
                      onRemoveReaction: (messageId, userId, emoji) {
                        _chatService.removeReaction(
                            widget.chatId, messageId, userId);
                      },
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: _typingStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData &&
                  snapshot.data == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [Text("Typing...")],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          ChatInput(
            onTyping: (isTyping) {
              _chatService.setTypingStatus(widget.chatId, _senderId!, isTyping);
            },
            onSend: (text) {
              if (_senderId == null || _receiverId == null) return;
              final msg = Message(
                senderId: _senderId!,
                receiverId: _receiverId!,
                text: text,
                timestamp: DateTime.now(),
              );
              _chatService.sendMessage(msg, widget.chatId);
            },
          ),
        ],
      ),
    );
  }
}
