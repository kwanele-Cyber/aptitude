import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:myapp/usecase/auth2/auth_service.dart';
import 'package:myapp/usecase/skill_match/widgets/invite_card.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});
  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Invite> _received = [];
  List<Invite> _sent = [];
  bool _loading = true;
  String? _myUid;
  final _inviteRepo = InviteRepository();
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _auth.getCurrentUser().then(
      (v) => {
        if (v != null) {_myUid = v.uid},
      },
    );
    _load();
  }

  //when screen is loading, fetch invites sent by you
  //and invites set by other users to you.
  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await _inviteRepo.listByRecipient(_myUid!);
    final s = await _inviteRepo.listBySender(_myUid!);
    setState(() {
      _received = r;
      _sent = s;
      _loading = false;
    });
  }

  //util method to update the status of an invite
  Future<void> _updateStatus(String id, InviteStatus status) async {
    await _inviteRepo.updateStatus(id, status);
    _load();
  }

  //build and render the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_received, true),
                        _buildList(_sent, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_received.where((d) => d.status == InviteStatus.pending).length} pending',
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
        color: Colors.white.withOpacity(0.05),
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

  Widget _buildList(List<Invite> list, bool isReceived) {
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
          onStatusUpdate: (status) => _updateStatus(invite.id, status),
        );
      },
    );
  }
}
