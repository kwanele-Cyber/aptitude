import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:myapp/usecase/connections/view_model/connections_view_model.dart';
import 'package:myapp/usecase/connections/widgets/invite_card.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:provider/provider.dart';

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConnectionsViewModel()..load(),
      child: const _ConnectionsScreenContent(),
    );
  }
}

class _ConnectionsScreenContent extends StatefulWidget {
  const _ConnectionsScreenContent();
  @override
  State<_ConnectionsScreenContent> createState() => _ConnectionsScreenContentState();
}

class _ConnectionsScreenContentState extends State<_ConnectionsScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  //build and render the UI
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConnectionsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(viewModel),
            _buildTabs(),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(viewModel, viewModel.received, true),
                        _buildList(viewModel, viewModel.sent, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ConnectionsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            'Connections',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${viewModel.received.where((d) => d.status == InviteStatus.pending).length} pending',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Received'),
          Tab(text: 'Sent'),
        ],
      ),
    );
  }

  Widget _buildList(ConnectionsViewModel viewModel, List<Invite> list, bool isReceived) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReceived ? Icons.inbox_outlined : Icons.send_outlined,
              size: 48,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 12),
            Text(
              isReceived ? 'No invites received' : 'No invites sent',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final invite = list[i];
        return InviteCard(
          invite: invite,
          isReceived: isReceived,
          onAccept: () => viewModel.acceptInvite(invite),
          onReject: () => viewModel.rejectInvite(invite.id),
          onMessage: () {
            final chatRepo = ChatRepository();
            final channelId = chatRepo.getChannelId(invite.from, invite.to);
            final peerName = isReceived ? invite.fromName : invite.toName;
            
            context.push('/chat/$channelId?name=$peerName');
          },
        );
      },
    );
  }
}

