import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';

class UpdateNotificationPreferencesUseCase {
  final NotificationRepository repository;

  UpdateNotificationPreferencesUseCase({required this.repository});

  Future<Either<Failure, void>> call(
      UpdateNotificationPreferencesParams params) async {
    return repository.updatePreferences(params.preferences);
  }
}

class UpdateNotificationPreferencesParams extends Equatable {
  final NotificationPreferencesEntity preferences;

  const UpdateNotificationPreferencesParams({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}
