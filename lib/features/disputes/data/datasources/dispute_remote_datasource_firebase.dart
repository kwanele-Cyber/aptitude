import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/disputes/data/datasources/dispute_remote_datasource.dart';
import 'package:myapp/features/disputes/data/models/dispute_model.dart';

class DisputeRemoteDataSourceFirebase implements DisputeRemoteDataSource {
  final FirebaseDatabase _database;

  DisputeRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _disputesRef => _database.ref('disputes');

  @override
  Future<void> createDispute(DisputeModel dispute) async {
    try {
      await _disputesRef.child(dispute.id).set(dispute.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateDispute(
      String disputeId, Map<String, dynamic> data) async {
    try {
      await _disputesRef.child(disputeId).update(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<DisputeModel?> getDispute(String disputeId) async {
    try {
      final snapshot = await _disputesRef.child(disputeId).get();
      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return DisputeModel.fromJson(disputeId, data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<DisputeModel>> fetchDisputesForUser(String userId) async {
    try {
      final snapshot = await _disputesRef
          .orderByChild('reporterId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) return [];

      final disputes = <DisputeModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;

      if (map != null) {
        map.forEach((key, value) {
          disputes.add(DisputeModel.fromJson(
              key, Map<String, dynamic>.from(value as Map)));
        });
      }

      disputes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return disputes;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<DisputeModel>> fetchAllDisputes() async {
    try {
      final snapshot = await _disputesRef.get();
      if (!snapshot.exists) return [];

      final disputes = <DisputeModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;

      if (map != null) {
        map.forEach((key, value) {
          disputes.add(DisputeModel.fromJson(
              key, Map<String, dynamic>.from(value as Map)));
        });
      }

      disputes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return disputes;
    } catch (e) {
      throw ServerException();
    }
  }
}
