import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const NotificationBadge({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService().getUnreadCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        return Stack(
          children: [
            IconButton(icon: child, onPressed: onTap),
            if (unreadCount > 0)
              Positioned(
                right: 8, top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
