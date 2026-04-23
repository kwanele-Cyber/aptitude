
import 'package:flutter/material.dart';
import '../models/message.dart';

// A widget to display a single chat message with appropriate styling.
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      // Align the bubble to the right if it's from the current user, otherwise to the left.
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary // Color for the user's own messages
              : theme.colorScheme.surfaceVariant, // Color for others' messages
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMe
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
