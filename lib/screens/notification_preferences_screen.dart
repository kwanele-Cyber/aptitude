import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences _prefs = NotificationPreferences();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    _prefs = await _notificationService.getUserPreferences('');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings'), backgroundColor: Colors.deepPurple),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 16),
                _buildSwitchTile('Push Notifications', 'Receive push notifications', _prefs.enablePush, (v) => _updatePreference('enablePush', v)),
                _buildSwitchTile('Email Notifications', 'Receive email notifications', _prefs.enableEmail, (v) => _updatePreference('enableEmail', v)),
                _buildSwitchTile('SMS Notifications', 'Receive SMS notifications', _prefs.enableSMS, (v) => _updatePreference('enableSMS', v)),
                const Divider(height: 32),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Notification Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                _buildSwitchTile('Match Notifications', 'When someone wants to exchange skills', _prefs.matchNotifications, (v) => _updatePreference('matchNotifications', v)),
                _buildSwitchTile('Message Notifications', 'When you receive a message', _prefs.messageNotifications, (v) => _updatePreference('messageNotifications', v)),
                _buildSwitchTile('Reminder Notifications', 'Before your scheduled sessions', _prefs.reminderNotifications, (v) => _updatePreference('reminderNotifications', v)),
                _buildSwitchTile('Rating Notifications', 'When someone rates your session', _prefs.ratingNotifications, (v) => _updatePreference('ratingNotifications', v)),
                _buildSwitchTile('Announcement Notifications', 'Platform announcements', _prefs.announcementNotifications, (v) => _updatePreference('announcementNotifications', v)),
              ],
            ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(value ? Icons.notifications_active : Icons.notifications_off, color: value ? Colors.deepPurple : Colors.grey),
    );
  }

  Future<void> _updatePreference(String key, bool value) async {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences updated')));
  }
}

// Add this method to NotificationService class
extension NotificationServicePrefs on NotificationService {
  Future<NotificationPreferences> getUserPreferences(String userId) async {
    return NotificationPreferences();
  }
}
