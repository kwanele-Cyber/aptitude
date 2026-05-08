import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_preferences_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/domain/usecases/fetch_notifications_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/get_preferences_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/send_notification_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/update_preferences_usecase.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_event.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockSendNotificationUseCase extends Mock
    implements SendNotificationUseCase {}

class MockFetchNotificationsUseCase extends Mock
    implements FetchNotificationsUseCase {}

class MockMarkNotificationReadUseCase extends Mock
    implements MarkNotificationReadUseCase {}

class MockGetNotificationPreferencesUseCase extends Mock
    implements GetNotificationPreferencesUseCase {}

class MockUpdateNotificationPreferencesUseCase extends Mock
    implements UpdateNotificationPreferencesUseCase {}

final tNotification = NotificationEntity(
  id: 'notif1',
  userId: 'user1',
  type: NotificationType.system,
  title: 'Welcome',
  body: 'Welcome!',
  createdAt: DateTime(2025, 1, 1),
);

final tPreferences = NotificationPreferencesEntity(
  userId: 'user1',
  notificationsEnabled: true,
  pushEnabled: true,
  emailEnabled: false,
);

void main() {
  late NotificationBloc bloc;
  late MockSendNotificationUseCase mockSendUseCase;
  late MockFetchNotificationsUseCase mockFetchUseCase;
  late MockMarkNotificationReadUseCase mockMarkReadUseCase;
  late MockGetNotificationPreferencesUseCase mockGetPrefsUseCase;
  late MockUpdateNotificationPreferencesUseCase mockUpdatePrefsUseCase;

  setUpAll(() {
    registerFallbackValue(const SendNotificationParams(
      userId: '',
      type: NotificationType.system,
      title: '',
      body: '',
    ));
    registerFallbackValue(const FetchNotificationsParams(userId: ''));
    registerFallbackValue(const MarkNotificationReadParams(notificationId: ''));
    registerFallbackValue(
        const GetNotificationPreferencesParams(userId: ''));
    registerFallbackValue(UpdateNotificationPreferencesParams(
      preferences: NotificationPreferencesEntity(userId: ''),
    ));
  });

  setUp(() {
    mockSendUseCase = MockSendNotificationUseCase();
    mockFetchUseCase = MockFetchNotificationsUseCase();
    mockMarkReadUseCase = MockMarkNotificationReadUseCase();
    mockGetPrefsUseCase = MockGetNotificationPreferencesUseCase();
    mockUpdatePrefsUseCase = MockUpdateNotificationPreferencesUseCase();

    bloc = NotificationBloc(
      sendNotificationUseCase: mockSendUseCase,
      fetchNotificationsUseCase: mockFetchUseCase,
      markNotificationReadUseCase: mockMarkReadUseCase,
      getPreferencesUseCase: mockGetPrefsUseCase,
      updatePreferencesUseCase: mockUpdatePrefsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FetchNotificationsRequested', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationsLoaded] on success',
      build: () {
        when(() => mockFetchUseCase(any()))
            .thenAnswer((_) async => Right([tNotification]));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchNotificationsRequested(userId: 'user1')),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationsLoaded>().having(
          (s) => s.notifications,
          'notifications',
          [tNotification],
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] on failure',
      build: () {
        when(() => mockFetchUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchNotificationsRequested(userId: 'user1')),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );
  });

  group('MarkNotificationReadRequested', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading] on success',
      build: () {
        when(() => mockMarkReadUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(MarkNotificationReadRequested(notificationId: 'notif1')),
      expect: () => [
        isA<NotificationLoading>(),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] on failure',
      build: () {
        when(() => mockMarkReadUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(MarkNotificationReadRequested(notificationId: 'notif1')),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );
  });

  group('SendNotificationRequested', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationSent] on success',
      build: () {
        when(() => mockSendUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(SendNotificationRequested(
        userId: 'user1',
        type: NotificationType.match,
        title: 'New Match',
        body: 'You have a match!',
      )),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationSent>(),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] on failure',
      build: () {
        when(() => mockSendUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(SendNotificationRequested(
        userId: 'user1',
        type: NotificationType.match,
        title: 'New Match',
        body: 'You have a match!',
      )),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );
  });

  group('FetchPreferencesRequested', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationPreferencesLoaded] on success',
      build: () {
        when(() => mockGetPrefsUseCase(any()))
            .thenAnswer((_) async => Right(tPreferences));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchPreferencesRequested(userId: 'user1')),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationPreferencesLoaded>().having(
          (s) => s.preferences,
          'preferences',
          tPreferences,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] on failure',
      build: () {
        when(() => mockGetPrefsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(FetchPreferencesRequested(userId: 'user1')),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );
  });

  group('UpdatePreferencesRequested', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationPreferencesUpdated] on success',
      build: () {
        when(() => mockUpdatePrefsUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdatePreferencesRequested(preferences: tPreferences),
      ),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationPreferencesUpdated>().having(
          (s) => s.preferences,
          'preferences',
          tPreferences,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] on failure',
      build: () {
        when(() => mockUpdatePrefsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdatePreferencesRequested(preferences: tPreferences),
      ),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );
  });
}
