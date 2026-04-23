
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';

// A stateful widget for the chat input field, handling message sending and typing indicators.
class ChatInput extends StatefulWidget {
  final String chatId;

  const ChatInput({super.key, required this.chatId});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService(); // Service to interact with Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _typingTimer; // Timer to detect when the user stops typing

  // Sends the message and cleans up the input field.
  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      _chatService.sendMessage(widget.chatId, _controller.text.trim());
      _controller.clear();
      // Immediately mark the user as not typing after sending.
      _updateTypingStatus(false);
      _typingTimer?.cancel(); // Cancel any existing timer
    }
  }

  // This function is called every time the text in the input field changes.
  void _onTextChanged(String text) {
    if (_auth.currentUser == null) return;

    // If a timer is already running, it means the user is still actively typing.
    // We cancel it and start a new one.
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();
    
    // Immediately notify that the user is typing.
    _updateTypingStatus(true);

    // Start a new timer. If this timer completes without being cancelled,
    // it means the user has stopped typing for the specified duration.
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _updateTypingStatus(false);
    });
  }

  // Calls the service to update the typing status in Firestore.
  void _updateTypingStatus(bool isTyping) {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      _chatService.updateTypingStatus(widget.chatId, currentUserId, isTyping);
    }
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks.
    _typingTimer?.cancel();
    _controller.dispose();
    // Ensure the user is marked as not typing when they leave the screen.
    _updateTypingStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            // A compatible, custom-built send button that works with all themes.
            Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(25.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(25.0),
                onTap: _sendMessage,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.send,
                    color: Colors.white, // Explicitly white for better contrast
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
