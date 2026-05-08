import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationChannel channel = NotificationChannel.push,
  });
  Future<Either<Failure, List<NotificationEntity>>> fetchNotifications(
      String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, NotificationPreferencesEntity>>
      getPreferences(String userId);
  Future<Either<Failure, void>> updatePreferences(
      NotificationPreferencesEntity preferences);
}
