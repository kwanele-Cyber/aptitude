import 'package:flutter/material.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/usecase/skill_match/view_model/chat_view_model.dart';
import 'package:myapp/usecase/skill_match/widgets/chat_bubble.dart';
import 'package:myapp/usecase/skill_match/widgets/agreement_proposal_sheet.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String channelId;
  final String peerName;

  const ChatScreen({
    super.key,
    required this.channelId,
    required this.peerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(channelId: widget.channelId)..init(),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          // Auto-scroll logic
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFF0F0F1A),
            appBar: _buildAppBar(viewModel),
            body: Column(
              children: [
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: viewModel.messages.length,
                          itemBuilder: (context, index) {
                            final msg = viewModel.messages[index];
                            return ChatBubble(
                              message: msg,
                              isMe: msg.senderId == viewModel.myUid,
                              onAcceptAgreement: (aid) => viewModel.respondToAgreement(aid, AgreementStatus.accepted),
                              onRejectAgreement: (aid) => viewModel.respondToAgreement(aid, AgreementStatus.rejected),
                            );
                          },
                        ),
                ),
                _buildInput(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatViewModel viewModel) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF7C3AED),
            child: Text(
              widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.peerName,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.handshake_outlined, color: Color(0xFF7C3AED)),
          onPressed: () => _showAgreementSheet(viewModel),
          tooltip: 'Propose Swap',
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildInput(ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.white30),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                final content = _messageController.text;
                if (content.isNotEmpty) {
                  viewModel.sendMessage(content);
                  _messageController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgreementSheet(ChatViewModel viewModel) async {
    // We need the channel to get commonSkills
    final chatRepo = ChatRepository();
    final channel = await chatRepo.getChannel(widget.channelId);
    if (channel == null) return;

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AgreementProposalSheet(
          channelId: widget.channelId,
          myId: viewModel.myUid ?? '',
          peerId: channel.participants.firstWhere((p) => p != viewModel.myUid),
          commonSkills: channel.commonSkills,
          onPropose: (agreement) => viewModel.proposeAgreement(agreement),
        ),
      );
    }
  }
}
