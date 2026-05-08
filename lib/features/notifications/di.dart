import 'package:get_it/get_it.dart';
import 'package:myapp/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:myapp/features/notifications/data/datasources/notification_remote_datasource_firebase.dart';
import 'package:myapp/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:myapp/features/notifications/domain/repository/notification_repository.dart';
import 'package:myapp/features/notifications/domain/usecases/fetch_notifications_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/get_preferences_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/send_notification_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/update_preferences_usecase.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_bloc.dart';

class NotificationDI {
  final GetIt sl;
  NotificationDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => NotificationBloc(
        sendNotificationUseCase: sl(),
        fetchNotificationsUseCase: sl(),
        markNotificationReadUseCase: sl(),
        getPreferencesUseCase: sl(),
        updatePreferencesUseCase: sl(),
      ),
    );

    sl.registerLazySingleton(
        () => SendNotificationUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => FetchNotificationsUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => MarkNotificationReadUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => GetNotificationPreferencesUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => UpdateNotificationPreferencesUseCase(repository: sl()));

    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
