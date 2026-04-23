
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  String _peerName = "Loading...";
  String _peerId = "";

  @override
  void initState() {
    super.initState();
    _getPeerInfo();
  }

  void _getPeerInfo() async {
    try {
      DocumentSnapshot convoDoc =
          await _chatService.getConversationDocument(widget.chatId);
      List<dynamic> members = convoDoc.get('members');
      final String currentUserId = _auth.currentUser!.uid;
      _peerId = members.firstWhere((id) => id != currentUserId, orElse: () => '');

      if (_peerId.isNotEmpty) {
        String name = await _chatService.getUserName(_peerId);
        if (mounted) {
          setState(() {
            _peerName = name;
          });
        }
      } else {
        if (mounted) setState(() => _peerName = "Chat");
      }
    } catch (e) {
      debugPrint("Error getting peer info: $e");
      if (mounted) setState(() => _peerName = "Chat");
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: StreamBuilder<DocumentSnapshot>(
        stream: _chatService.getConversationStream(widget.chatId),
        builder: (context, snapshot) {
          Widget titleContent = Text(_peerName); // Default title

          if (snapshot.hasData && _peerId.isNotEmpty) {
            var data = snapshot.data!.data() as Map<String, dynamic>?;
            var typingStatus = data?['typingStatus'] as Map<String, dynamic>? ?? {};
            bool isPeerTyping = typingStatus[_peerId] ?? false;

            // Programmatically build the list of children to ensure compatibility.
            final List<Widget> columnChildren = [Text(_peerName)];
            if (isPeerTyping) {
              columnChildren.add(
                const Text(
                  'Typing...',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              );
            }

            titleContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren,
            );
          }

          return titleContent;
        },
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool isMe) {
    return MessageBubble(message: message, isMe: isMe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error loading messages.'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data ?? [];
                return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      bool isMe = message.senderId == _auth.currentUser!.uid;
                      return _buildMessageItem(message, isMe);
                    });
              },
            ),
          ),
          ChatInput(chatId: widget.chatId),
        ],
      ),
    );
  }
}
