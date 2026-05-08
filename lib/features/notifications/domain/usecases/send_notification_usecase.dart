import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository repository;

  SendNotificationUseCase({required this.repository});

  Future<Either<Failure, void>> call(SendNotificationParams params) async {
    return repository.sendNotification(
      userId: params.userId,
      type: params.type,
      title: params.title,
      body: params.body,
      data: params.data,
      channel: params.channel,
    );
  }
}

class SendNotificationParams extends Equatable {
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final NotificationChannel channel;

  const SendNotificationParams({
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.channel = NotificationChannel.push,
  });

  @override
  List<Object?> get props => [userId, type, title, body, data, channel];
}
