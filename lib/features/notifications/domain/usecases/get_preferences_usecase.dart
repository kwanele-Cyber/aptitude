import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';

class GetNotificationPreferencesUseCase {
  final NotificationRepository repository;

  GetNotificationPreferencesUseCase({required this.repository});

  Future<Either<Failure, NotificationPreferencesEntity>> call(
      GetNotificationPreferencesParams params) async {
    return repository.getPreferences(params.userId);
  }
}

class GetNotificationPreferencesParams extends Equatable {
  final String userId;

  const GetNotificationPreferencesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
