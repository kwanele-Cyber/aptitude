import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatInput extends StatelessWidget {
  final String chatId;
  final ChatService chatService;
  final controller = TextEditingController();

  ChatInput({required this.chatId, required this.chatService, Key? key}) : super(key: key);

  void sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (controller.text.trim().isEmpty || user == null) return;

    final message = Message(
      senderId: user.uid,
      receiverId: 'general', // This should be updated based on your app logic
      text: controller.text.trim(),
      timestamp: DateTime.now(),
    );
    chatService.sendMessage(chatId, message);
    controller.clear();
  }

  void sendImage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    chatService.sendImage(chatId, user.uid, 'general');
  }

  void sendFile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    chatService.sendFile(chatId, user.uid, 'general');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.blueAccent),
            onPressed: sendImage,
            tooltip: "Send an Image",
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
            onPressed: sendFile,
            tooltip: "Send a File",
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            mini: true,
            onPressed: sendMessage,
            child: const Icon(Icons.send, size: 18),
            backgroundColor: Colors.blueAccent,
            elevation: 2.0,
          ),
        ],
      ),
    );
  }
}
