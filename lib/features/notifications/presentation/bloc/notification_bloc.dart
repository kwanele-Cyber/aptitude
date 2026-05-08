import 'package:bloc/bloc.dart';
import 'package:myapp/features/notifications/domain/usecases/fetch_notifications_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/get_preferences_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/send_notification_usecase.dart';
import 'package:myapp/features/notifications/domain/usecases/update_preferences_usecase.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_event.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  final SendNotificationUseCase sendNotificationUseCase;
  final FetchNotificationsUseCase fetchNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final GetNotificationPreferencesUseCase getPreferencesUseCase;
  final UpdateNotificationPreferencesUseCase updatePreferencesUseCase;

  NotificationBloc({
    required this.sendNotificationUseCase,
    required this.fetchNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.getPreferencesUseCase,
    required this.updatePreferencesUseCase,
  }) : super(NotificationInitial()) {
    on<FetchNotificationsRequested>(_onFetchNotifications);
    on<MarkNotificationReadRequested>(_onMarkRead);
    on<SendNotificationRequested>(_onSendNotification);
    on<FetchPreferencesRequested>(_onFetchPreferences);
    on<UpdatePreferencesRequested>(_onUpdatePreferences);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await fetchNotificationsUseCase(
      FetchNotificationsParams(userId: event.userId),
    );
    await result.fold(
      (left) async =>
          emit(NotificationError(message: 'Failed to fetch notifications')),
      (right) async => emit(NotificationsLoaded(notifications: right)),
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await markNotificationReadUseCase(
      MarkNotificationReadParams(notificationId: event.notificationId),
    );
    await result.fold(
      (left) async =>
          emit(NotificationError(message: 'Failed to mark as read')),
      (right) async {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updated = currentState.notifications.map((n) {
            if (n.id == event.notificationId) {
              return n; // will be re-fetched
            }
            return n;
          }).toList();
          emit(NotificationsLoaded(notifications: updated));
        }
      },
    );
  }

  Future<void> _onSendNotification(
    SendNotificationRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await sendNotificationUseCase(
      SendNotificationParams(
        userId: event.userId,
        type: event.type,
        title: event.title,
        body: event.body,
        data: event.data,
        channel: event.channel,
      ),
    );
    await result.fold(
      (left) async =>
          emit(NotificationError(message: 'Failed to send notification')),
      (right) async => emit(NotificationSent()),
    );
  }

  Future<void> _onFetchPreferences(
    FetchPreferencesRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await getPreferencesUseCase(
      GetNotificationPreferencesParams(userId: event.userId),
    );
    await result.fold(
      (left) async =>
          emit(NotificationError(message: 'Failed to load preferences')),
      (right) async =>
          emit(NotificationPreferencesLoaded(preferences: right)),
    );
  }

  Future<void> _onUpdatePreferences(
    UpdatePreferencesRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await updatePreferencesUseCase(
      UpdateNotificationPreferencesParams(preferences: event.preferences),
    );
    await result.fold(
      (left) async =>
          emit(NotificationError(message: 'Failed to update preferences')),
      (right) async => emit(
        NotificationPreferencesUpdated(preferences: event.preferences),
      ),
    );
  }
}
