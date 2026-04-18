import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final ChatService _chatService = ChatService();

  ChatScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessagesStream(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      MessageBubble(message: messages[index]),
                );
              },
            ),
          ),
          ChatInput(
            onSend: (text) {
              final msg = Message(
                senderId: "currentUserId", // replace with FirebaseAuth user
                receiverId: "receiverId", // replace with target user
                text: text,
                timestamp: DateTime.now(),
              );
              _chatService.sendMessage(msg, chatId);
            },
          ),
        ],
      ),
    );
  }
}
