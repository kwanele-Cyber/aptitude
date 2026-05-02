import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/notification_model.dart';
import 'package:myapp/core/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
            child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _buildNotificationTile(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel notification) {
    final provider = context.read<NotificationProvider>();
    final timeStr = DateFormat('jm').format(notification.timestamp);
    
    IconData icon;
    Color color;
    
    switch (notification.type) {
      case NotificationType.message:
        icon = Icons.chat_bubble_outline;
        color = const Color(0xFF3B82F6);
        break;
      case NotificationType.agreement:
        icon = Icons.handshake_outlined;
        color = const Color(0xFF10B981);
        break;
      case NotificationType.session:
        icon = Icons.event_outlined;
        color = const Color(0xFF7C3AED);
        break;
      case NotificationType.rating:
        icon = Icons.star_outline;
        color = Colors.amber;
        break;
      default:
        icon = Icons.notifications_none;
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) provider.markAsRead(notification.id);
        // Add navigation logic here based on type if needed
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.white.withOpacity(0.05) : const Color(0xFF7C3AED).withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications at the moment.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
