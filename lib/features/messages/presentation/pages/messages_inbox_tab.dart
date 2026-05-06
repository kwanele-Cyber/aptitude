import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/domain/usecases/admin_usecases.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/messages/domain/entity/inbox_conversation_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';
import 'package:myapp/features/messages/domain/usecases/create_room_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/watch_inbox_usecase.dart';
import 'package:myapp/features/messages/presentation/pages/room_chat_page.dart';
import 'package:myapp/injection_container.dart';

class MessagesInboxTab extends widgets.StatefulWidget {
  const MessagesInboxTab({super.key});

  @override
  widgets.State<MessagesInboxTab> createState() => _MessagesInboxTabState();
}

class _MessagesInboxTabState extends widgets.State<MessagesInboxTab> {
  late final Future<List<AdminUserEntity>> _usersFuture;
  late final Stream<Either<Failure, List<InboxConversationEntity>>> _inboxStream;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.userEntity.id;
      _inboxStream = sl<WatchInboxUseCase>().call(authState.userEntity.id);
    } else {
      _inboxStream = Stream<Either<Failure, List<InboxConversationEntity>>>.empty();
    }
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
        failure is ServerFailure
            ? failure.message ?? 'Unable to load users.'
            : 'Unable to load users.',
      ),
      (users) => users.where((user) => user.id != currentUserId).toList(),
    );
  }

  Future<void> _createRoom() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    late final List<AdminUserEntity> users;
    try {
      users = await _usersFuture;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load users for room creation.')),
      );
      return;
    }

    if (!mounted || users.isEmpty) return;

    final draft = await showModalBottomSheet<_RoomDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CreateRoomSheet(users: users),
    );

    if (draft == null || draft.selectedUsers.isEmpty) return;

    final memberIds = <String>{
      authState.userEntity.id,
      ...draft.selectedUsers.map((user) => user.id),
    }.toList();

    final room = RoomEntity(
      id: '',
      name: draft.name.trim(),
      createdBy: authState.userEntity.id,
      memberIds: memberIds,
      createdAt: DateTime.now(),
    );

    final result = await sl<CreateRoomUseCase>().call(CreateRoomParams(room: room));
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message ?? 'Unable to create room.')),
        );
      },
      (roomId) {
        final memberNames = <String, String>{
          authState.userEntity.id: authState.userEntity.name,
          for (final user in draft.selectedUsers) user.id: user.name,
        };

        context.push(
          '/rooms/$roomId',
          extra: RoomChatArgs(
            room: RoomEntity(
              id: roomId,
              name: room.name,
              createdBy: room.createdBy,
              memberIds: room.memberIds,
              createdAt: room.createdAt,
            ),
            memberNames: memberNames,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Create room',
            onPressed: _createRoom,
            icon: const Icon(Icons.group_add_outlined),
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

          final List<AdminUserEntity> allUsers = snapshot.data ?? <AdminUserEntity>[];
          return StreamBuilder<Either<Failure, List<InboxConversationEntity>>>(
            stream: _inboxStream,
            builder: (context, inboxSnapshot) {
              if (inboxSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final inboxResult = inboxSnapshot.data;
              if (inboxResult == null) {
                return _EmptyInbox(
                  onBrowseSkills: () => context.push('/skills/feed'),
                );
              }

              return inboxResult.fold(
                (failure) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      failure.message ?? 'Unable to load inbox.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
                (conversations) {
                  final Map<String, AdminUserEntity> usersById = {
                    for (final user in allUsers) user.id: user,
                  };
                  final List<_InboxListItem> items = conversations
                      .map((conversation) {
                        if (conversation.isRoom) {
                          return _InboxListItem(conversation: conversation);
                        }

                        final user = usersById[conversation.conversationId];
                        if (user == null) return null;

                        return _InboxListItem(user: user, conversation: conversation);
                      })
                      .whereType<_InboxListItem>()
                      .toList();

                  if (items.isEmpty) {
                    return _EmptyInbox(
                      onBrowseSkills: () => context.push('/skills/feed'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
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
                          leading: item.conversation.isRoom
                              ? CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.12),
                                  foregroundColor: theme.colorScheme.secondary,
                                  child: const Icon(Icons.groups_rounded),
                                )
                              : CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                  foregroundColor: theme.colorScheme.primary,
                                  child: Text(item.user!.initials),
                                ),
                          title: Text(item.conversation.isRoom
                              ? item.conversation.title
                              : item.user!.name),
                          subtitle: Text(
                            item.conversation.lastSenderId == _currentUserId
                                ? 'You: ${item.conversation.lastMessage}'
                                : item.conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(item.conversation.lastMessageTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              if (item.conversation.unreadCount > 0) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${item.conversation.unreadCount}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            if (item.conversation.isRoom) {
                              final memberNames = {
                                for (final user in allUsers) user.id: user.name,
                              };
                              context.push(
                                '/rooms/${item.conversation.conversationId}',
                                extra: RoomChatArgs(
                                  room: RoomEntity(
                                    id: item.conversation.conversationId,
                                    name: item.conversation.title,
                                    createdBy: item.conversation.createdBy ?? '',
                                    memberIds: item.conversation.memberIds ?? const [],
                                    createdAt: item.conversation.createdAt ?? DateTime.now(),
                                  ),
                                  memberNames: memberNames,
                                ),
                              );
                            } else {
                              context.push('/messages/${item.user!.id}', extra: item.user);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
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

class _EmptyInbox extends widgets.StatelessWidget {
  final VoidCallback onBrowseSkills;

  const _EmptyInbox({required this.onBrowseSkills});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 46,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your inbox will show everyone you have sent messages to or received messages from.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onBrowseSkills,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse Skills'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxListItem {
  final AdminUserEntity? user;
  final InboxConversationEntity conversation;

  const _InboxListItem({
    this.user,
    required this.conversation,
  });
}

class _RoomDraft {
  final String name;
  final List<AdminUserEntity> selectedUsers;

  const _RoomDraft({
    required this.name,
    required this.selectedUsers,
  });
}

class _CreateRoomSheet extends widgets.StatefulWidget {
  final List<AdminUserEntity> users;

  const _CreateRoomSheet({required this.users});

  @override
  widgets.State<_CreateRoomSheet> createState() => _CreateRoomSheetState();
}

class _CreateRoomSheetState extends widgets.State<_CreateRoomSheet> {
  final TextEditingController _roomNameController = TextEditingController();
  final Set<String> _selectedIds = <String>{};

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final canCreate =
        _selectedIds.isNotEmpty && _roomNameController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Create room',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose people to start a group conversation.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _roomNameController,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Room name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.separated(
              itemCount: widget.users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = widget.users[index];
                final selected = _selectedIds.contains(user.id);
                return CheckboxListTile(
                  value: selected,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(user.id);
                      } else {
                        _selectedIds.remove(user.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canCreate
                  ? () {
                      final selectedUsers = widget.users
                          .where((user) => _selectedIds.contains(user.id))
                          .toList();
                      Navigator.of(context).pop(
                        _RoomDraft(
                          name: _roomNameController.text.trim(),
                          selectedUsers: selectedUsers,
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.groups_rounded),
              label: const Text('Create room'),
            ),
          ),
        ],
      ),
    );
  }
}
