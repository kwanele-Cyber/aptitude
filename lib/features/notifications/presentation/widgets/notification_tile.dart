import 'package:flutter/material.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Icons.people_alt;
      case NotificationType.message:
        return Icons.chat;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.agreement:
        return Icons.description;
      case NotificationType.session:
        return Icons.event;
      case NotificationType.feedback:
        return Icons.rate_review;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Colors.green;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.agreement:
        return Colors.purple;
      case NotificationType.session:
        return Colors.teal;
      case NotificationType.feedback:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(notification.type);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(_iconForType(notification.type), color: color, size: 20),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            notification.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(notification.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}/${time.year}';
  }
}
