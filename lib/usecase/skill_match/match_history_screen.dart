import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/match.dart';
import 'package:myapp/usecase/skill_match/view_model/match_history_view_model.dart';

import 'package:provider/provider.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchHistoryViewModel()..loadHistory(),
      child: const _MatchHistoryContent(),
    );
  }
}

class _MatchHistoryContent extends StatelessWidget {
  const _MatchHistoryContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MatchHistoryViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Match History', style: TextStyle(color: Colors.white, fontSize: 18)),
          bottom: const TabBar(
            indicatorColor: Color(0xFF7C3AED),
            labelColor: Color(0xFF7C3AED),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Saved'),
              Tab(text: 'Accepted'),
              Tab(text: 'Declined'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HistoryList(items: viewModel.saved, emptyMessage: 'No saved matches'),
            _HistoryList(items: viewModel.accepted, emptyMessage: 'No accepted matches'),
            _HistoryList(
              items: [...viewModel.rejected, ...viewModel.ignored], 
              emptyMessage: 'No declined matches'
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<MatchHistoryItem> items;
  final String emptyMessage;

  const _HistoryList({required this.items, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MatchHistoryViewModel>();

    if (items.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final user = item.peer;

        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF7C3AED),
              child: Text(user.firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  'Status: ${item.match.status.name.toUpperCase()}',
                  style: TextStyle(
                    color: _getStatusColor(item.match.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<MatchStatus>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (status) => viewModel.updateStatus(item.match.id, status),
              itemBuilder: (context) => [
                if (item.match.status != MatchStatus.accepted)
                  const PopupMenuItem(value: MatchStatus.accepted, child: Text('Accept')),
                if (item.match.status != MatchStatus.saved)
                  const PopupMenuItem(value: MatchStatus.saved, child: Text('Save')),
                if (item.match.status != MatchStatus.rejected)
                  const PopupMenuItem(value: MatchStatus.rejected, child: Text('Reject')),
              ],
            ),
            onTap: () => context.push('/profile/${user.uid}'),
          ),
        );
      },
    );
  }

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.accepted: return const Color(0xFF22C55E);
      case MatchStatus.saved: return const Color(0xFF7C3AED);
      case MatchStatus.rejected: return Colors.redAccent;
      case MatchStatus.ignored: return Colors.grey;
      default: return Colors.white;
    }
  }
}
