import 'package:equatable/equatable.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class NotificationPreferencesEntity extends Equatable {
  final String userId;
  final bool notificationsEnabled;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final Map<NotificationType, bool> typePreferences;

  const NotificationPreferencesEntity({
    required this.userId,
    this.notificationsEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
    this.typePreferences = const {},
  });

  NotificationPreferencesEntity copyWith({
    String? userId,
    bool? notificationsEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    Map<NotificationType, bool>? typePreferences,
  }) {
    return NotificationPreferencesEntity(
      userId: userId ?? this.userId,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      typePreferences: typePreferences ?? this.typePreferences,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        notificationsEnabled,
        pushEnabled,
        emailEnabled,
        smsEnabled,
        typePreferences,
      ];
}
