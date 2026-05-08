import 'package:equatable/equatable.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  NotificationsLoaded({
    required this.notifications,
    int? unreadCount,
  }) : unreadCount = unreadCount ??
            notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationSent extends NotificationState {
  @override
  List<Object?> get props => [];
}

class NotificationPreferencesLoaded extends NotificationState {
  final NotificationPreferencesEntity preferences;

  NotificationPreferencesLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class NotificationPreferencesUpdated extends NotificationState {
  final NotificationPreferencesEntity preferences;

  NotificationPreferencesUpdated({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
