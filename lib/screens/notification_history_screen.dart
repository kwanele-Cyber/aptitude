import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final NotificationService _notificationService = NotificationService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.mark_chat_read), onPressed: _markAllAsRead),
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearAll),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.getUserNotifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) => _buildNotificationCard(notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notification.isRead ? Colors.grey.shade300 : Colors.deepPurple, width: notification.isRead ? 1 : 2),
      ),
      child: ListTile(
        leading: Icon(_getIcon(notification.type), color: _getIconColor(notification.type)),
        title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(_formatDate(notification.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        trailing: notification.isRead ? null : Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle)),
        isThreeLine: true,
        onTap: () async {
          if (!notification.isRead) {
            await _notificationService.markAsRead(notification.id);
            setState(() {});
          }
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'match': return Icons.people;
      case 'message': return Icons.message;
      case 'reminder': return Icons.alarm;
      case 'rating': return Icons.star;
      case 'announcement': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'match': return Colors.green;
      case 'message': return Colors.blue;
      case 'reminder': return Colors.orange;
      case 'rating': return Colors.amber;
      case 'announcement': return Colors.red;
      default: return Colors.deepPurple;
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read')));
  }

  Future<void> _clearAll() async {
    setState(() {});
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }
}
