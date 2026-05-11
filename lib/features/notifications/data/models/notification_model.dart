import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    super.data,
    super.isRead,
    super.channel,
    required super.createdAt,
    super.readAt,
  });

  factory NotificationModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return NotificationModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : null,
      isRead: json['isRead'] as bool? ?? false,
      channel: _parseChannel(json['channel'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'channel': channel.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  static NotificationType _parseType(String? type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.system,
    );
  }

  static NotificationChannel _parseChannel(String? channel) {
    return NotificationChannel.values.firstWhere(
      (e) => e.name == channel,
      orElse: () => NotificationChannel.push,
    );
  }
}
