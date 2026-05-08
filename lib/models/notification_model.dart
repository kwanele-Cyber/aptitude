import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'match', 'message', 'reminder', 'rating', 'announcement'
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.scheduledFor,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      data: map['data'],
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      scheduledFor: map['scheduledFor'] != null 
          ? DateTime.parse(map['scheduledFor']) 
          : null,
      imageUrl: map['imageUrl'],
    );
  }
}

class NotificationPreferences {
  final bool enablePush;
  final bool enableEmail;
  final bool enableSMS;
  final bool matchNotifications;
  final bool messageNotifications;
  final bool reminderNotifications;
  final bool ratingNotifications;
  final bool announcementNotifications;

  NotificationPreferences({
    this.enablePush = true,
    this.enableEmail = true,
    this.enableSMS = false,
    this.matchNotifications = true,
    this.messageNotifications = true,
    this.reminderNotifications = true,
    this.ratingNotifications = true,
    this.announcementNotifications = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'enablePush': enablePush,
      'enableEmail': enableEmail,
      'enableSMS': enableSMS,
      'matchNotifications': matchNotifications,
      'messageNotifications': messageNotifications,
      'reminderNotifications': reminderNotifications,
      'ratingNotifications': ratingNotifications,
      'announcementNotifications': announcementNotifications,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      enablePush: map['enablePush'] ?? true,
      enableEmail: map['enableEmail'] ?? true,
      enableSMS: map['enableSMS'] ?? false,
      matchNotifications: map['matchNotifications'] ?? true,
      messageNotifications: map['messageNotifications'] ?? true,
      reminderNotifications: map['reminderNotifications'] ?? true,
      ratingNotifications: map['ratingNotifications'] ?? true,
      announcementNotifications: map['announcementNotifications'] ?? true,
    );
  }
}
