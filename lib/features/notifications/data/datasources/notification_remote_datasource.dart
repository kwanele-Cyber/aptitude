import 'package:myapp/features/notifications/data/models/notification_model.dart';
import 'package:myapp/features/notifications/data/models/notification_preferences_model.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationChannel channel = NotificationChannel.push,
  });
  Future<List<NotificationModel>> fetchNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<NotificationPreferencesModel> getPreferences(String userId);
  Future<void> updatePreferences(NotificationPreferencesModel preferences);
}

class NotificationRemoteDataSourceMock implements NotificationRemoteDataSource {
  @override
  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationChannel channel = NotificationChannel.push,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<NotificationPreferencesModel> getPreferences(
      String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return NotificationPreferencesModel(userId: userId);
  }

  @override
  Future<void> updatePreferences(
      NotificationPreferencesModel preferences) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
