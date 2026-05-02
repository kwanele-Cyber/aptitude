import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/chat/view_model/chat_list_view_model.dart';
import 'package:myapp/usecase/chat/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListViewModel>().loadChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatListViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : viewModel.entries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: viewModel.loadChannels,
                  color: const Color(0xFF7C3AED),
                  backgroundColor: const Color(0xFF1A1A2E),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: viewModel.entries.length,
                    itemBuilder: (context, index) {
                      final entry = viewModel.entries[index];
                      return _buildChatTile(context, entry);
                    },
                  ),
                ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatListEntry entry) {
    final time = DateTime.fromMillisecondsSinceEpoch(entry.channel.lastMessageTimestamp);
    final timeStr = DateFormat('jm').format(time);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          final peerName = '${entry.peer.firstName} ${entry.peer.lastName}';
          context.push('/chat/${entry.channel.id}?name=${Uri.encodeComponent(peerName)}')
            .then((_) => context.read<ChatListViewModel>().loadChannels());
        },
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          child: Center(
            child: Text(
              entry.peer.firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${entry.peer.firstName} ${entry.peer.lastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            entry.channel.lastMessage.isEmpty ? 'Start a conversation' : entry.channel.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Match with someone to start chatting!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

