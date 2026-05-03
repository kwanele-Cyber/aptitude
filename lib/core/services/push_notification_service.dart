import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/utils/logger.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final UserRepository _userRepo = UserRepository();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request permissions (especially for iOS and Web)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Log.d('User granted notification permissions');
    } else {
      Log.w('User declined or has not accepted notification permissions');
    }

    // 2. Initialize Local Notifications for Foreground (not supported on web)
    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: DarwinInitializationSettings(),
          );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          Log.d('Notification tapped: ${response.payload}');
        },
      );
    }

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.d('Received foreground message: ${message.notification?.title}');

      // On web, the service worker handles background notifications.
      // In foreground, the browser ignores service worker notifications,
      // so we fall back to logging.
      if (!kIsWeb) {
        _showLocalNotification(message);
      }
    });

    // 4. Handle Background/Terminated state clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.d('App opened via notification: ${message.data}');
    });

    _isInitialized = true;
  }

  Future<void> updateToken(String uid) async {
    try {
      String? token;
      if (kIsWeb) {
        token = await _fcm.getToken(vapidKey: null);
      } else {
        token = await _fcm.getToken();
      }
      if (token != null) {
        await _userRepo.update(uid, {'fcmToken': token});
        Log.d('FCM Token updated for user $uid');
      }

      // Listen for token refreshes (noop stream on web, but harmless)
      _fcm.onTokenRefresh.listen((newToken) {
        _userRepo.update(uid, {'fcmToken': newToken});
      });
    } catch (e) {
      Log.e('Error updating FCM token', e);
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'chat_messages',
            'Chat Messages',
            channelDescription: 'Notifications for incoming chat messages',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }
}
