import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String, String, String, String) onReaction;
  final Function(String, String, String) onRemoveReaction;

  const MessageBubble({
    required this.message,
    required this.onReaction,
    required this.onRemoveReaction,
  });

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            final userId = FirebaseAuth.instance.currentUser!.uid;
            if (message.reactions.containsKey(userId)) {
              onRemoveReaction(message.id!, userId, message.reactions[userId]!);
            }
            onReaction(message.id!, userId, emoji.emoji, message.id!);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;

    return GestureDetector(
      onLongPress: () => _showEmojiPicker(context),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[200] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text),
              if (message.reactions.isNotEmpty) ...[
                SizedBox(height: 5),
                Wrap(
                  spacing: 4.0,
                  children: message.reactions.entries
                      .map((e) => Text(e.value))
                      .toList(),
                ),
              ],
              if (isMe && message.isRead) ...[
                SizedBox(height: 5),
                Icon(Icons.done_all, size: 16, color: Colors.blue),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
