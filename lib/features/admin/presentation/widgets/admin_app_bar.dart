import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/auth/domain/entity/user_role.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AdminAppBar({super.key, this.title = 'Admin Dashboard'});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(title),
      centerTitle: false,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () {},
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) return const SizedBox.shrink();
            final user = state.userEntity;
            return PopupMenuButton<_AdminMenuAction>(
              offset: const Offset(0, 48),
              onSelected: (action) {
                if (action == _AdminMenuAction.signOut) {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: theme.textTheme.titleSmall),
                      Text(user.email, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: _AdminMenuAction.signOut,
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      const Text('Sign Out'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (user.firstName.isNotEmpty ? user.firstName[0] : '') +
                            (user.lastName.isNotEmpty ? user.lastName[0] : ''),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.userRole == UserRole.admin
                            ? Colors.amber.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: user.userRole == UserRole.admin
                              ? Colors.amber.shade800
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

enum _AdminMenuAction { signOut }
