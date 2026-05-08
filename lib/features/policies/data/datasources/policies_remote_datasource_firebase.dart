import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/policies/data/datasources/policies_remote_datasource.dart';
import 'package:myapp/features/policies/data/models/policy_acknowledgment_model.dart';
import 'package:myapp/features/policies/data/models/policy_model.dart';

class PoliciesRemoteDataSourceFirebase implements PoliciesRemoteDataSource {
  final FirebaseDatabase _database;

  PoliciesRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _policiesRef => _database.ref('policies');
  DatabaseReference _acknowledgmentsRef(String userId) =>
      _database.ref('policy_acknowledgments').child(userId);

  @override
  Future<List<PolicyModel>> getPolicies() async {
    try {
      final snapshot = await _policiesRef.get();
      if (!snapshot.exists) return [];

      final policies = <PolicyModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map != null) {
        map.forEach((key, value) {
          final data = Map<String, dynamic>.from(value as Map);
          policies.add(PolicyModel.fromJson(key, data));
        });
      }
      return policies;
    } catch (e) {
      throw ServerException('Failed to load policies');
    }
  }

  @override
  Future<List<PolicyAcknowledgmentModel>> getAcknowledgments(
      String userId) async {
    try {
      final snapshot = await _acknowledgmentsRef(userId).get();
      if (!snapshot.exists) return [];

      final acknowledgments = <PolicyAcknowledgmentModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map != null) {
        map.forEach((key, value) {
          final data = Map<String, dynamic>.from(value as Map);
          acknowledgments.add(
              PolicyAcknowledgmentModel.fromJson(key, data));
        });
      }
      return acknowledgments;
    } catch (e) {
      throw ServerException('Failed to load acknowledgments');
    }
  }

  @override
  Future<void> acknowledgePolicy(
      String userId, String policyId, String version) async {
    try {
      final data = {
        'acknowledgedAt': DateTime.now().toIso8601String(),
        'version': version,
      };
      await _acknowledgmentsRef(userId).child(policyId).set(data);
    } catch (e) {
      throw ServerException('Failed to acknowledge policy');
    }
  }
}
