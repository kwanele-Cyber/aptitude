import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';

class FetchNotificationsUseCase {
  final NotificationRepository repository;

  FetchNotificationsUseCase({required this.repository});

  Future<Either<Failure, List<NotificationEntity>>> call(
      FetchNotificationsParams params) async {
    return repository.fetchNotifications(params.userId);
  }
}

class FetchNotificationsParams extends Equatable {
  final String userId;

  const FetchNotificationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
