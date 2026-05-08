import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings, onDidReceiveNotificationResponse: _onNotificationTap);
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    
    final token = await _fcm.getToken();
    if (token != null && _auth.currentUser != null) {
      await _saveTokenToFirestore(token);
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  Future<void> _showLocalNotification({required String title, required String body, String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'skill_exchange_channel',
      'Skill Exchange Notifications',
      channelDescription: 'Notifications for skill exchange activities',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(DateTime.now().millisecondsSinceEpoch.remainder(100000), title, body, details, payload: payload);
  }

  Future<void> sendNotification({required String userId, required String title, required String body, required String type, Map<String, dynamic>? data}) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('notifications').doc(notification.id).set(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('notifications').where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).get();
    for (var doc in snapshot.docs) batch.update(doc.reference, {'isRead': true});
    await batch.commit();
  }

  Stream<int> getUnreadCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);
    return _firestore.collection('notifications').where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).snapshots().map((snapshot) => snapshot.docs.length);
  }

  Future<void> sendBroadcastNotification({required String title, required String body, required String type, List<String>? targetUserIds}) async {
    QuerySnapshot usersSnapshot;
    if (targetUserIds != null) {
      usersSnapshot = await _firestore.collection('users').where('userId', whereIn: targetUserIds).get();
    } else {
      usersSnapshot = await _firestore.collection('users').get();
    }
    for (var userDoc in usersSnapshot.docs) {
      await sendNotification(userId: userDoc.id, title: title, body: body, type: type);
    }
    await _firestore.collection('announcements').add({
      'title': title,
      'body': body,
      'type': type,
      'sentAt': FieldValue.serverTimestamp(),
      'sentBy': _auth.currentUser?.uid,
    });
  }
}
