import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class NotificationPreferencesModel extends NotificationPreferencesEntity {
  const NotificationPreferencesModel({
    required super.userId,
    super.notificationsEnabled,
    super.pushEnabled,
    super.emailEnabled,
    super.smsEnabled,
    super.typePreferences,
  });

  factory NotificationPreferencesModel.fromJson(
      String userId, Map<String, dynamic> json) {
    final rawPreferences = json['typePreferences'] is Map
        ? Map<String, dynamic>.from(json['typePreferences'] as Map)
        : <String, dynamic>{};

    final typePreferences = <NotificationType, bool>{};
    for (final entry in rawPreferences.entries) {
      final type = _parseType(entry.key);
      typePreferences[type] = entry.value as bool? ?? true;
    }

    return NotificationPreferencesModel(
      userId: userId,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? false,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      typePreferences: typePreferences,
    );
  }

  Map<String, dynamic> toJson() {
    final typePrefsJson = <String, bool>{};
    for (final entry in typePreferences.entries) {
      typePrefsJson[entry.key.name] = entry.value;
    }

    return {
      'notificationsEnabled': notificationsEnabled,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'typePreferences': typePrefsJson,
    };
  }

  static NotificationType _parseType(String? type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.system,
    );
  }
}
