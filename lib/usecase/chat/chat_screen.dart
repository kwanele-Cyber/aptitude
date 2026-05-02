import 'package:flutter/material.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/usecase/chat/view_model/chat_view_model.dart';
import 'package:myapp/usecase/chat/widgets/chat_bubble.dart';
import 'package:myapp/usecase/chat/widgets/agreement_message_card.dart';
import 'package:myapp/usecase/chat/widgets/agreement_proposal_sheet.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/repositories/block_repository.dart';
import 'package:myapp/core/widgets/report_dialog.dart';
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
                          child: CircularProgressIndicator(
                            color: Color(0xFF7C3AED),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: viewModel.messages.length,
                          itemBuilder: (context, index) {
                            final msg = viewModel.messages[index];
                            return ChatBubble(
                              message: msg,
                              isMe: msg.senderId == viewModel.myUid,
                              onAcceptAgreement: (aid) =>
                                  viewModel.respondToAgreement(
                                    aid,
                                    AgreementStatus.accepted,
                                  ),
                              onRejectAgreement: (aid) =>
                                  viewModel.respondToAgreement(
                                    aid,
                                    AgreementStatus.rejected,
                                  ),
                              onCancelAgreement: viewModel.cancelAgreement,
                              onModifyAgreement:
                                  (aid, sessions, minutes, frequency) =>
                                      viewModel.modifyAgreement(
                                        agreementId: aid,
                                        sessionsCount: sessions,
                                        minutesPerSession: minutes,
                                        frequency: frequency,
                                      ),
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
              widget.peerName.isNotEmpty
                  ? widget.peerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.peerName,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              if (viewModel.peerIsTyping)
                const Text(
                  'typing...',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF60A5FA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.fact_check_outlined, color: Colors.white70),
          onPressed: () => _showAgreementsSheet(viewModel),
          tooltip: 'View Agreements',
        ),
        IconButton(
          icon: const Icon(Icons.handshake_outlined, color: Color(0xFF7C3AED)),
          onPressed: () => _showAgreementSheet(viewModel),
          tooltip: 'Propose Swap',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: const Color(0xFF1A1A2E),
          onSelected: (val) async {
            if (val == 'report') {
              final chatRepo = ChatRepository();
              final channel = await chatRepo.getChannel(widget.channelId);
              if (channel == null) return;
              final peerId = channel.participants.firstWhere(
                (p) => p != viewModel.myUid,
              );

              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => ReportDialog(
                    reportedUserId: peerId,
                    context: 'chat_${widget.channelId}',
                  ),
                );
              }
            } else if (val == 'block') {
              _confirmBlock(context, viewModel);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Report User',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block_flipped, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Block User',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _showAgreementsSheet(ChatViewModel viewModel) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FutureBuilder<List<Agreement>>(
          future: viewModel.getChannelAgreements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              );
            }

            final agreements = snapshot.data ?? [];
            if (agreements.isEmpty) {
              return const Center(
                child: Text(
                  'No agreements yet',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agreements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: agreements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final agreement = agreements[index];
                      return AgreementMessageCard(
                        agreementId: agreement.id,
                        isMe: agreement.proposerId == viewModel.myUid,
                        onAccept: () => viewModel.respondToAgreement(
                          agreement.id,
                          AgreementStatus.accepted,
                        ),
                        onReject: () => viewModel.respondToAgreement(
                          agreement.id,
                          AgreementStatus.rejected,
                        ),
                        onCancel: () => viewModel.cancelAgreement(agreement.id),
                        onModify: (sessions, minutes, frequency) =>
                            viewModel.modifyAgreement(
                              agreementId: agreement.id,
                              sessionsCount: sessions,
                              minutesPerSession: minutes,
                              frequency: frequency,
                            ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
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
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.white30),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) =>
                      viewModel.updateTypingStatus(val.isNotEmpty),
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

  void _confirmBlock(BuildContext context, ChatViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Block User?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You will no longer see messages from this user, and they will be removed from your matches.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final myUid = viewModel.myUid;
              if (myUid == null) return;

              final chatRepo = ChatRepository();
              final channel = await chatRepo.getChannel(widget.channelId);
              if (channel == null) return;

              final peerId = channel.participants.firstWhere((p) => p != myUid);

              await BlockRepository().blockUser(myUid, peerId);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close chat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User blocked'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text(
              'Block',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
