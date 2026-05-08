import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:myapp/features/notifications/data/models/notification_model.dart';
import 'package:myapp/features/notifications/data/models/notification_preferences_model.dart';
import 'package:myapp/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:myapp/features/notifications/domain/entity/notification_channel.dart';
import 'package:myapp/features/notifications/domain/entity/notification_entity.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';

class MockNotificationRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

final tNotificationModel = NotificationModel(
  id: 'notif1',
  userId: 'user1',
  type: NotificationType.system,
  title: 'Welcome',
  body: 'Welcome to the app!',
  createdAt: DateTime(2025, 1, 1),
);

final tPrefsModel = NotificationPreferencesModel(userId: 'user1');

void main() {
  late NotificationRepositoryImpl repository;
  late MockNotificationRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockNotificationRemoteDataSource();
    repository = NotificationRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('sendNotification', () {
    test('should send notification on success', () async {
      when(() => mockRemote.sendNotification(
            userId: 'user1',
            type: NotificationType.match,
            title: 'Match',
            body: 'New match',
            data: null,
            channel: NotificationChannel.push,
          )).thenAnswer((_) async {});

      final result = await repository.sendNotification(
        userId: 'user1',
        type: NotificationType.match,
        title: 'Match',
        body: 'New match',
      );

      expect(result.isRight(), true);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.sendNotification(
            userId: 'user1',
            type: NotificationType.match,
            title: 'Match',
            body: 'New match',
            data: null,
            channel: NotificationChannel.push,
          )).thenThrow(ServerException());

      final result = await repository.sendNotification(
        userId: 'user1',
        type: NotificationType.match,
        title: 'Match',
        body: 'New match',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.sendNotification(
            userId: 'user1',
            type: NotificationType.match,
            title: 'Match',
            body: 'New match',
            data: null,
            channel: NotificationChannel.push,
          )).thenThrow(Exception());

      final result = await repository.sendNotification(
        userId: 'user1',
        type: NotificationType.match,
        title: 'Match',
        body: 'New match',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchNotifications', () {
    test('should fetch notifications on success', () async {
      when(() => mockRemote.fetchNotifications('user1'))
          .thenAnswer((_) async => [tNotificationModel]);

      final result = await repository.fetchNotifications('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<NotificationEntity>>());
      verify(() => mockRemote.fetchNotifications('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchNotifications('user1'))
          .thenThrow(ServerException());

      final result = await repository.fetchNotifications('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchNotifications('user1'))
          .thenThrow(Exception());

      final result = await repository.fetchNotifications('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('markAsRead', () {
    test('should mark notification as read on success', () async {
      when(() => mockRemote.markAsRead('notif1'))
          .thenAnswer((_) async {});

      final result = await repository.markAsRead('notif1');

      expect(result.isRight(), true);
      verify(() => mockRemote.markAsRead('notif1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.markAsRead('notif1'))
          .thenThrow(ServerException());

      final result = await repository.markAsRead('notif1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.markAsRead('notif1'))
          .thenThrow(Exception());

      final result = await repository.markAsRead('notif1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getPreferences', () {
    test('should get preferences on success', () async {
      when(() => mockRemote.getPreferences('user1'))
          .thenAnswer((_) async => tPrefsModel);

      final result = await repository.getPreferences('user1');

      expect(result.isRight(), true);
      verify(() => mockRemote.getPreferences('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getPreferences('user1'))
          .thenThrow(ServerException());

      final result = await repository.getPreferences('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.getPreferences('user1'))
          .thenThrow(Exception());

      final result = await repository.getPreferences('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updatePreferences', () {
    test('should update preferences on success', () async {
      when(() => mockRemote.updatePreferences(tPrefsModel))
          .thenAnswer((_) async {});

      final result = await repository.updatePreferences(tPrefsModel);

      expect(result.isRight(), true);
      verify(() => mockRemote.updatePreferences(tPrefsModel)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updatePreferences(tPrefsModel))
          .thenThrow(ServerException());

      final result = await repository.updatePreferences(tPrefsModel);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updatePreferences(tPrefsModel))
          .thenThrow(Exception());

      final result = await repository.updatePreferences(tPrefsModel);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
