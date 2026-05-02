import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/notification_model.dart';
import 'package:myapp/core/data/repositories/notification_repository.dart';
import 'package:myapp/core/services/auth_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  final AuthService _auth = AuthService();
  
  List<NotificationModel> _notifications = [];
  StreamSubscription? _subscription;
  String? _currentUid;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void init() async {
    final user = await _auth.getCurrentUser();
    if (user != null) {
      _currentUid = user.uid;
      _subscription?.cancel();
      _subscription = _repo.streamNotifications(user.uid).listen((list) {
        _notifications = list;
        notifyListeners();
      });
    }
  }

  Future<void> markAsRead(String id) async {
    if (_currentUid != null) {
      await _repo.markAsRead(_currentUid!, id);
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUid != null) {
      await _repo.markAllAsRead(_currentUid!);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
