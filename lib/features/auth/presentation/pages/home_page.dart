import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/domain/usecases/admin_usecases.dart';
import 'package:myapp/features/auth/domain/entity/conversation_entity.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_bloc.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_event.dart';
import 'package:myapp/features/matchmaking/presentation/pages/matchmaking_page.dart';
import 'package:myapp/features/messages/presentation/pages/messages_inbox_tab.dart';
import 'package:myapp/injection_container.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<MatchBloc>()
          .add(FetchMatchesRequested(userId: authState.userEntity.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ExploreTab(),
          _MatchesTab(),
          MessagesInboxTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            activeIcon: Icon(Icons.handshake),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- Explore Tab ---
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF5F5CFF),
                      const Color(0xFF3BB2FF),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Skills',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Learn, teach, and grow together',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const Spacer(),
                        TextField(
                          readOnly: true,
                          onTap: () => context.push('/skills/search'),
                          decoration: InputDecoration(
                            hintText: 'Search skills...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        label: 'Offer Skill',
                        subtitle: 'Share your knowledge',
                        color: const Color(0xFFF0F4FF),
                        onTap: () => context.push('/skills/create'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        label: 'Learn Skill',
                        subtitle: 'Explore opportunities',
                        color: const Color(0xFFF4F0FF),
                        onTap: () => context.push('/skills/create-request'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _PeopleSection(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Browse Feed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/skills/feed'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _feedItems.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _FeedCard(item: _feedItems[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'More',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _MenuItem(
                        label: 'Match History',
                        onTap: () {
                          final state = context.read<AuthBloc>().state;
                          if (state is AuthAuthenticated) {
                            context.push('/matches/history/${state.userEntity.id}');
                          }
                        },
                      ),
                      Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                      _MenuItem(
                        label: 'Filter Skills',
                        onTap: () => context.push('/skills/filter'),
                      ),
                      Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                      _MenuItem(
                        label: 'Saved Searches',
                        onTap: () {
                          final state = context.read<AuthBloc>().state;
                          if (state is AuthAuthenticated) {
                            context.push('/skills/saved-searches/${state.userEntity.id}');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

const _feedItems = [
  // example feed items now include the creator info so we can offer a "Chat" action
  _FeedData('Photography Basics', Color(0xFFE3F2FD), creatorId: 'user_1', creatorName: 'Ava'),
  _FeedData('Flutter for Beginners', Color(0xFFF3E5F5), creatorId: 'user_2', creatorName: 'Liam'),
  _FeedData('Watercolor Painting', Color(0xFFFFF3E0), creatorId: 'user_3', creatorName: 'Maya'),
  _FeedData('Guitar Lessons', Color(0xFFE8F5E9), /* no creator => no chat button */),
  _FeedData('Cooking 101', Color(0xFFFFEBEE), creatorId: 'user_4', creatorName: 'Noah'),
];

class _FeedData {
  final String title;
  final Color color;
  final String? creatorId;
  final String? creatorName;

  const _FeedData(this.title, this.color, {this.creatorId, this.creatorName});
}

class _PeopleSection extends StatefulWidget {
  const _PeopleSection();

  @override
  State<_PeopleSection> createState() => _PeopleSectionState();
}

class _PeopleSectionState extends State<_PeopleSection> {
  late final Future<List<AdminUserEntity>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<AdminUserEntity>> _loadUsers() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return [];
    }

    final currentUserId = authState.userEntity.id;
    final result = await sl<GetUsersUseCase>().call();

    return result.fold(
      (failure) {
        throw Exception(
          failure is ServerFailure
              ? failure.message ?? 'Unable to load users.'
              : 'Unable to load users.',
        );
      },
      (users) => users.where((user) => user.id != currentUserId).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'People on Aptitude',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<AdminUserEntity>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 144,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 144,
                child: Center(
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              );
            }

            final users = snapshot.data ?? const <AdminUserEntity>[];
            if (users.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No other users are available yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return InkWell(
                    onTap: () => context.push('/profile/${user.id}'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.onPrimaryContainer,
                            child: Text(user.initials),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- Matches Tab ---
class _MatchesTab extends StatelessWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Matches'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              context.push('/matches');
            },
          ),
        ],
      ),
      body: const MatchmakingPage(),
    );
  }
}

// --- Messages Tab ---
class _MessagesTab extends StatefulWidget {
  const _MessagesTab();

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  late final Future<List<AdminUserEntity>> _usersFuture;
  bool _showAllUsers = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<AdminUserEntity>> _loadUsers() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return [];
    }

    final currentUserId = authState.userEntity.id;
    final result = await sl<GetUsersUseCase>().call();

    return result.fold(
      (failure) => throw Exception(
          failure is ServerFailure ? failure.message ?? 'Unable to load users.' : 'Unable to load users.'),
      (users) => users.where((user) => user.id != currentUserId).toList(),
    );
  }

  List<AdminUserEntity> _getFilteredUsers(List<AdminUserEntity> allUsers) {
    if (_showAllUsers) {
      return allUsers;
    }

    // Show only users with conversations
    final conversations = ConversationService.getConversations();
    final conversationUserIds = conversations.map((c) => c.userId).toSet();

    return allUsers.where((user) => conversationUserIds.contains(user.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showAllUsers = !_showAllUsers),
            icon: Icon(_showAllUsers ? Icons.chat : Icons.group_add),
            label: Text(_showAllUsers ? 'Recent' : 'All Users'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<AdminUserEntity>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            );
          }

          final allUsers = snapshot.data ?? [];
          final filteredUsers = _getFilteredUsers(allUsers);

          if (filteredUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _showAllUsers ? Icons.group_off : Icons.chat_outlined,
                        size: 48,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _showAllUsers ? 'No users found' : 'No conversations yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showAllUsers
                          ? 'There are no other users on the platform yet.'
                          : 'Start a conversation by messaging someone from the skills section.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_showAllUsers)
                      FilledButton.icon(
                        onPressed: () => setState(() => _showAllUsers = true),
                        icon: const Icon(Icons.group_add),
                        label: const Text('Browse All Users'),
                      ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final conversationList = ConversationService.getConversations()
                  .where((c) => c.userId == user.id)
                  .toList();
              final conversation = conversationList.isEmpty ? null : conversationList.first;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    foregroundColor: theme.colorScheme.primary,
                    child: Text(user.initials),
                  ),
                  title: Text(user.name),
                  subtitle: conversation != null
                      ? Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text('${user.email} • ${user.role}'),
                  trailing: conversation != null
                      ? Text(
                          _formatTime(conversation.lastMessageTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        )
                      : const Icon(Icons.chat_bubble_outline),
                  onTap: () {
                    ConversationService.markAsRead(user.id);
                    context.push('/messages/${user.id}', extra: user);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

// --- Profile Tab ---
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }
        final user = state.userEntity;
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        MediaQuery.of(context).padding.top + 20,
                        24,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  (user.firstName.isNotEmpty ? user.firstName[0] : '') +
                                      (user.lastName.isNotEmpty ? user.lastName[0] : ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _StatBadge(label: 'Skills', value: '—'),
                              const SizedBox(width: 24),
                              _StatBadge(label: 'Matches', value: '—'),
                              const SizedBox(width: 24),
                              _StatBadge(label: 'Rating', value: '—'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Menu items
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.lock_outline,
                        label: 'Change Password',
                        onTap: () => context.push('/change-password'),
                      ),
                      const SizedBox(height: 8),
                      _ProfileMenuItem(
                        icon: Icons.shield_outlined,
                        label: 'Two-Factor Authentication',
                        onTap: () => context.push('/2fa-setup'),
                      ),
                      const SizedBox(height: 8),
                      _ProfileMenuItem(
                        icon: Icons.history,
                        label: 'Match History',
                        onTap: () => context.push(
                          '/matches/history/${user.id}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ProfileMenuItem(
                        icon: Icons.download_outlined,
                        label: 'Export Data',
                        onTap: () => context.push('/export-data'),
                      ),
                      const SizedBox(height: 8),
                      _ProfileMenuItem(
                        icon: Icons.restart_alt_outlined,
                        label: 'Account Recovery',
                        onTap: () => context.push('/account-recovery'),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                            context.read<AuthBloc>().add(AuthLogoutRequested()),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () =>
                            context.read<AuthBloc>().add(AuthDeleteAccountRequested()),
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('Delete Account'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.withValues(alpha: 0.7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Reusable Widgets ---

class _QuickActionCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final _FeedData item;
  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () => context.push('/skills/feed'),
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.title.split(' ').map((w) => w[0]).take(2).join(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: item.color == const Color(0xFFE3F2FD)
                            ? Colors.blue.shade300
                            : item.color == const Color(0xFFF3E5F5)
                                ? Colors.purple.shade300
                                : item.color == const Color(0xFFFFF3E0)
                                    ? Colors.orange.shade300
                                    : item.color == const Color(0xFFE8F5E9)
                                        ? Colors.green.shade300
                                        : Colors.red.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Chat button row: shown only when a creator is available
              if (item.creatorId != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.creatorName ?? 'Creator',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          // navigate to messages for the creator
                          context.push('/messages/${item.creatorId}');
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
