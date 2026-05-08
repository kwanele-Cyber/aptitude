import 'package:equatable/equatable.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotificationsRequested extends NotificationEvent {
  final String userId;

  FetchNotificationsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationReadRequested extends NotificationEvent {
  final String notificationId;

  MarkNotificationReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class SendNotificationRequested extends NotificationEvent {
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final NotificationChannel channel;

  SendNotificationRequested({
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.channel = NotificationChannel.push,
  });

  @override
  List<Object?> get props => [userId, type, title, body, data, channel];
}

class FetchPreferencesRequested extends NotificationEvent {
  final String userId;

  FetchPreferencesRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdatePreferencesRequested extends NotificationEvent {
  final NotificationPreferencesEntity preferences;

  UpdatePreferencesRequested({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}
