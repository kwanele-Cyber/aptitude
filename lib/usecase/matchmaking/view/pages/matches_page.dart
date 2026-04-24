import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/matchmaking/match_viewmodel.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/core/models/match_model.dart';
import 'package:myapp/usecase/chatsystem/chat_viewmodel.dart';
import 'package:go_router/go_router.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<MatchViewModel>().loadSavedMatches(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MatchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Matches'),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake, color: Colors.cyanAccent),
            onPressed: () => context.push('/agreements'),
            tooltip: 'My Agreements',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = context.read<AuthViewModel>().user;
              if (user != null) {
                context.read<MatchViewModel>().generateAndSaveMatches(user.uid);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Top Mentors for You',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSearchBar(viewModel),
            _buildFilterChips(viewModel),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : viewModel.error != null
                      ? Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.redAccent)))
                      : _buildMatchesList(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(MatchViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) => viewModel.setSearchQuery(value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search skills...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(MatchViewModel viewModel) {
    final statuses = ['all', 'pending', 'accepted', 'declined'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final isSelected = viewModel.statusFilter == status;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ChoiceChip(
                label: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) viewModel.setStatusFilter(status);
                },
                selectedColor: Colors.cyanAccent,
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMatchesList(MatchViewModel viewModel) {
    final matches = viewModel.filteredMatches;

    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No matches found matching your filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final viewModel = context.read<MatchViewModel>();
    
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.skillName,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Match Score: ${(match.confidenceScore * 100).toInt()}%',
                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    _buildMatchIndicator(match.confidenceScore),
                  ],
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: IconButton(
                    icon: const Icon(Icons.visibility_off_outlined, color: Colors.white24, size: 18),
                    onPressed: () => viewModel.updateMatchStatus(match.id, 'ignored'),
                    tooltip: 'Ignore this match',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (match.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.updateMatchStatus(match.id, 'declined'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.updateMatchStatus(match.id, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else if (match.status == 'accepted')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Accepted', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final currentUserId = context.read<AuthViewModel>().user?.uid;
                      if (currentUserId != null) {
                        final roomId = await context.read<ChatViewModel>().initiateChat(currentUserId, match.teacherUid);
                        if (roomId != null && mounted) {
                          context.push('/chat/$roomId');
                        }
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              )
            else if (match.status == 'declined')
              const Center(
                child: Text('You declined this match', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/profile/${match.teacherUid}'),
                child: const Text('View Mentor Profile', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchIndicator(double score) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Icon(
          score > 0.9 ? Icons.bolt : Icons.trending_up,
          color: Colors.cyanAccent,
          size: 24,
        ),
      ),
    );
  }
}
