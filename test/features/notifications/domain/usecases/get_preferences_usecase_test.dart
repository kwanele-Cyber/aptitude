import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';
import 'package:myapp/features/notifications/domain/usecases/get_preferences_usecase.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

final tPreferences = NotificationPreferencesEntity(
  userId: 'user1',
  notificationsEnabled: true,
  pushEnabled: true,
  emailEnabled: false,
);

void main() {
  late MockNotificationRepository mockRepository;
  late GetNotificationPreferencesUseCase useCase;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = GetNotificationPreferencesUseCase(repository: mockRepository);
  });

  group('GetNotificationPreferencesUseCase', () {
    const params = GetNotificationPreferencesParams(userId: 'user1');

    test('should get preferences on success', () async {
      when(() => mockRepository.getPreferences(any()))
          .thenAnswer((_) async => Right(tPreferences));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getPreferences('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getPreferences(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
