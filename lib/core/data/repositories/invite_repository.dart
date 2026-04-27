import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:uuid/uuid.dart';

class InviteRepository {
  final String _basePath = "invites";
  late final DatabaseService<DataSnapshot> _databaseService;

  InviteRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> sendInvite(Invite invite) async {
    await _databaseService.create(
      location: '$_basePath/${invite.id}',
      data: invite.toJson(),
    );
  }

  Future<bool> hasExistingInvite(String fromUid, String toUid) async {
    final snapshot = await _databaseService.list(location: _basePath);
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> invitesMap = snapshot.value as Map;
      return invitesMap.values.any((invite) =>
          invite['from'] == fromUid && invite['to'] == toUid);
    }
    return false;
  }

  Future<void> updateStatus(String inviteId, InviteStatus status) async {
    await _databaseService.update(
      location: '$_basePath/$inviteId',
      data: {'status': status.name},
    );
  }

  Future<List<Invite>> listByRecipient(String toUid) async {
    final snapshot = await _databaseService.list(location: _basePath);
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> invitesMap = snapshot.value as Map;
      return invitesMap.values
          .where((invite) => invite['to'] == toUid)
          .map((invite) => Invite.fromJson(Map<String, dynamic>.from(invite as Map)))
          .toList();
    }
    return [];
  }

  Future<List<Invite>> listBySender(String fromUid) async {
    final snapshot = await _databaseService.list(location: _basePath);
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> invitesMap = snapshot.value as Map;
      return invitesMap.values
          .where((invite) => invite['from'] == fromUid)
          .map((invite) => Invite.fromJson(Map<String, dynamic>.from(invite as Map)))
          .toList();
    }
    return [];
  }
}
