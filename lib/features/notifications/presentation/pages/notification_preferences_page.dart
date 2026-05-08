import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_event.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_state.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  late NotificationPreferencesEntity _preferences;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
            FetchPreferencesRequested(userId: authState.userEntity.id),
          );
    }
    _preferences = const NotificationPreferencesEntity(userId: '');
  }

  void _updatePreference({
    bool? notificationsEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    final updated = _preferences.copyWith(
      notificationsEnabled: notificationsEnabled,
      pushEnabled: pushEnabled,
      emailEnabled: emailEnabled,
      smsEnabled: smsEnabled,
    );
    setState(() => _preferences = updated);
    context.read<NotificationBloc>().add(
          UpdatePreferencesRequested(preferences: updated),
        );
  }

  void _updateTypePreference(NotificationType type, bool value) {
    final updatedPrefs =
        Map<NotificationType, bool>.from(_preferences.typePreferences)
          ..[type] = value;
    final updated = _preferences.copyWith(typePreferences: updatedPrefs);
    setState(() => _preferences = updated);
    context.read<NotificationBloc>().add(
          UpdatePreferencesRequested(preferences: updated),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationPreferencesLoaded ||
              state is NotificationPreferencesUpdated) {
            final prefs = state is NotificationPreferencesLoaded
                ? state.preferences
                : (state as NotificationPreferencesUpdated).preferences;
            _preferences = prefs;
            return _buildPreferences(prefs);
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Ready'));
        },
      ),
    );
  }

  Widget _buildPreferences(NotificationPreferencesEntity prefs) {
    return ListView(
      children: [
        const _SectionHeader(title: 'Global Settings'),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Master toggle for all notifications'),
          value: prefs.notificationsEnabled,
          onChanged: (v) => _updatePreference(notificationsEnabled: v),
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive push notifications on your device'),
          value: prefs.pushEnabled,
          onChanged: prefs.notificationsEnabled
              ? (v) => _updatePreference(pushEnabled: v)
              : null,
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive notifications via email'),
          value: prefs.emailEnabled,
          onChanged: prefs.notificationsEnabled
              ? (v) => _updatePreference(emailEnabled: v)
              : null,
        ),
        SwitchListTile(
          title: const Text('SMS Notifications'),
          subtitle: const Text('Receive notifications via SMS'),
          value: prefs.smsEnabled,
          onChanged: prefs.notificationsEnabled
              ? (v) => _updatePreference(smsEnabled: v)
              : null,
        ),
        const _SectionHeader(title: 'Notification Types'),
        for (final type in NotificationType.values)
          _TypePreferenceTile(
            type: type,
            value: prefs.typePreferences[type] ?? true,
            enabled: prefs.notificationsEnabled,
            onChanged: (v) => _updateTypePreference(type, v),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _TypePreferenceTile extends StatelessWidget {
  final NotificationType type;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _TypePreferenceTile({
    required this.type,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  String _typeLabel(NotificationType t) {
    switch (t) {
      case NotificationType.match:
        return 'Match Notifications';
      case NotificationType.message:
        return 'Message Notifications';
      case NotificationType.reminder:
        return 'Reminder Notifications';
      case NotificationType.system:
        return 'System Notifications';
      case NotificationType.agreement:
        return 'Agreement Notifications';
      case NotificationType.session:
        return 'Session Notifications';
      case NotificationType.feedback:
        return 'Feedback Notifications';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(_typeLabel(type)),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}
