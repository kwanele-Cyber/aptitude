import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';
import 'package:myapp/features/notifications/domain/usecases/fetch_notifications_usecase.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

final tNotification = NotificationEntity(
  id: 'notif1',
  userId: 'user1',
  type: NotificationType.system,
  title: 'Welcome',
  body: 'Welcome to the app!',
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  late MockNotificationRepository mockRepository;
  late FetchNotificationsUseCase useCase;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = FetchNotificationsUseCase(repository: mockRepository);
  });

  group('FetchNotificationsUseCase', () {
    const params = FetchNotificationsParams(userId: 'user1');

    test('should fetch notifications on success', () async {
      when(() => mockRepository.fetchNotifications(any()))
          .thenAnswer((_) async => Right([tNotification]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.fetchNotifications('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.fetchNotifications(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
