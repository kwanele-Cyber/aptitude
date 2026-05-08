import 'package:equatable/equatable.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final NotificationChannel channel;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    this.channel = NotificationChannel.push,
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        data,
        isRead,
        channel,
        createdAt,
        readAt,
      ];
}
