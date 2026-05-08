import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:myapp/features/notifications/data/models/notification_model.dart';
import 'package:myapp/features/notifications/data/models/notification_preferences_model.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class NotificationRemoteDataSourceFirebase
    implements NotificationRemoteDataSource {
  final FirebaseDatabase _database;

  NotificationRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference _notificationsRef(String userId) =>
      _database.ref('notifications').child(userId);

  DatabaseReference _preferencesRef(String userId) =>
      _database.ref('notificationPreferences').child(userId);

  @override
  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationChannel channel = NotificationChannel.push,
  }) async {
    try {
      final notificationRef = _notificationsRef(userId).push();
      final notification = NotificationModel(
        id: notificationRef.key ?? '',
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        channel: channel,
        createdAt: DateTime.now(),
      );
      await notificationRef.set(notification.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final snapshot = await _notificationsRef(userId)
          .orderByChild('createdAt')
          .limitToLast(50)
          .get();
      if (!snapshot.exists) return [];

      final map =
          snapshot.value is Map ? Map<String, dynamic>.from(snapshot.value as Map) : null;
      if (map == null) return [];

      final notifications = <NotificationModel>[];
      map.forEach((key, value) {
        notifications.add(
            NotificationModel.fromJson(key, Map<String, dynamic>.from(value as Map)));
      });
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final parts = notificationId.split('_');
      if (parts.length < 2) return;
      final userId = parts[0];
      await _notificationsRef(userId)
          .child(notificationId)
          .update({'isRead': true, 'readAt': DateTime.now().toIso8601String()});
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<NotificationPreferencesModel> getPreferences(String userId) async {
    try {
      final snapshot = await _preferencesRef(userId).get();
      if (!snapshot.exists || snapshot.value == null) {
        return NotificationPreferencesModel(userId: userId);
      }
      return NotificationPreferencesModel.fromJson(
        userId,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updatePreferences(
      NotificationPreferencesModel preferences) async {
    try {
      await _preferencesRef(preferences.userId).set(preferences.toJson());
    } catch (e) {
      throw ServerException();
    }
  }
}
