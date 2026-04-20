import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMe = FirebaseAuth.instance.currentUser?.uid == message.senderId;
    final senderInitial = message.senderId.isNotEmpty ? message.senderId[0].toUpperCase() : '?';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe)
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(senderInitial, style: const TextStyle(color: Colors.white)),
                  ),
                if (!isMe) const SizedBox(width: 8),
                Text(
                  isMe ? "You" : "User ${message.senderId.substring(0, 5)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.blue[800] : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            if (message.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message.imageUrl!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            if (message.fileUrl != null)
              InkWell(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(message.fileUrl!))) {
                    await launchUrl(Uri.parse(message.fileUrl!));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[50] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      const Text(
                        "File Attached",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}