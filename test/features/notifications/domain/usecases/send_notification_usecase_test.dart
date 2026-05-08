import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';
import 'package:myapp/features/notifications/domain/usecases/send_notification_usecase.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;
  late SendNotificationUseCase useCase;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = SendNotificationUseCase(repository: mockRepository);
  });

  group('SendNotificationUseCase', () {
    const params = SendNotificationParams(
      userId: 'user1',
      type: NotificationType.match,
      title: 'New Match',
      body: 'You have a new match!',
    );

    test('should send notification on success', () async {
      when(() => mockRepository.sendNotification(
            userId: 'user1',
            type: NotificationType.match,
            title: 'New Match',
            body: 'You have a new match!',
            data: null,
            channel: NotificationChannel.push,
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.sendNotification(
            userId: 'user1',
            type: NotificationType.match,
            title: 'New Match',
            body: 'You have a new match!',
            data: null,
            channel: NotificationChannel.push,
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.sendNotification(
            userId: 'user1',
            type: NotificationType.match,
            title: 'New Match',
            body: 'You have a new match!',
            data: null,
            channel: NotificationChannel.push,
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
