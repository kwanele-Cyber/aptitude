import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';
import 'package:myapp/features/notifications/domain/usecases/update_preferences_usecase.dart';

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
  late UpdateNotificationPreferencesUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tPreferences);
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = UpdateNotificationPreferencesUseCase(repository: mockRepository);
  });

  group('UpdateNotificationPreferencesUseCase', () {
    test('should update preferences on success', () async {
      when(() => mockRepository.updatePreferences(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(
        UpdateNotificationPreferencesParams(preferences: tPreferences),
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.updatePreferences(tPreferences)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updatePreferences(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        UpdateNotificationPreferencesParams(preferences: tPreferences),
      );

      expect(result.isLeft(), true);
    });
  });
}
