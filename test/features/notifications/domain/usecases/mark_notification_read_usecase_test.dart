import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';
import 'package:myapp/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;
  late MarkNotificationReadUseCase useCase;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = MarkNotificationReadUseCase(repository: mockRepository);
  });

  group('MarkNotificationReadUseCase', () {
    const params = MarkNotificationReadParams(notificationId: 'notif1');

    test('should mark notification as read on success', () async {
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.markAsRead('notif1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
