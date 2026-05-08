import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:myapp/features/notifications/data/models/notification_preferences_model.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationChannel channel = NotificationChannel.push,
  }) async {
    try {
      await remoteDataSource.sendNotification(
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        channel: channel,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> fetchNotifications(
      String userId) async {
    try {
      final notifications = await remoteDataSource.fetchNotifications(userId);
      return Right(notifications);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NotificationPreferencesEntity>> getPreferences(
      String userId) async {
    try {
      final preferences = await remoteDataSource.getPreferences(userId);
      return Right(preferences);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
      NotificationPreferencesEntity preferences) async {
    try {
      await remoteDataSource
          .updatePreferences(preferences as NotificationPreferencesModel);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
