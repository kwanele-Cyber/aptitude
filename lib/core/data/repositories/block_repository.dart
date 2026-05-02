import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class BlockRepository {
  final String _path = "blocks";
  late final DatabaseService<DataSnapshot> _databaseService;

  BlockRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> blockUser(String myUid, String targetUid) async {
    final ref = FirebaseDatabase.instance.ref("$_path/$myUid/$targetUid");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      throw ChatException('User is already blocked', ErrorCode.alreadyBlocked);
    }

    try {
      await ref.set(DateTime.now().toIso8601String());
    } catch (e) {
      throw ChatException('Failed to block user', ErrorCode.databaseError, e);
    }
  }

  Future<void> unblockUser(String myUid, String targetUid) async {
    await FirebaseDatabase.instance.ref("$_path/$myUid/$targetUid").remove();
  }

  Future<List<String>> getBlockedList(String myUid) async {
    final snapshot = await FirebaseDatabase.instance.ref("$_path/$myUid").get();
    if (snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.keys.map((k) => k.toString()).toList();
    }
    return [];
  }

  Stream<List<String>> streamBlockedList(String myUid) {
    return FirebaseDatabase.instance.ref("$_path/$myUid").onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final Map<dynamic, dynamic> map = event.snapshot.value as Map;
      return map.keys.map((k) => k.toString()).toList();
    });
  }
}
