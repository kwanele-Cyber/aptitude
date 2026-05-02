import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/notification_model.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class NotificationRepository {
  final String _path = "notifications";
  late final DatabaseService<DataSnapshot> _databaseService;

  NotificationRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return FirebaseDatabase.instance
        .ref("$_path/$uid")
        .orderByChild("timestamp")
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final Map<dynamic, dynamic> map = event.snapshot.value as Map;
      final list = map.values
          .map((v) => NotificationModel.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
      // Sort descending by timestamp
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> sendNotification(String uid, NotificationModel notification) async {
    await _databaseService.create(
      location: "$_path/$uid/${notification.id}",
      data: notification.toJson(),
    );
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    await FirebaseDatabase.instance.ref("$_path/$uid/$notificationId").update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final ref = FirebaseDatabase.instance.ref("$_path/$uid");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map;
      final updates = <String, dynamic>{};
      for (var key in data.keys) {
        updates["$key/isRead"] = true;
      }
      await ref.update(updates);
    }
  }
}
