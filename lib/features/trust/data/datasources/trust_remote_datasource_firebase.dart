import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/trust/data/datasources/trust_remote_datasource.dart';
import 'package:myapp/features/trust/data/models/trust_model.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:uuid/uuid.dart';

class TrustRemoteDataSourceFirebase implements TrustRemoteDataSource {
  final FirebaseDatabase _database;

  TrustRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _trustRef => _database.ref('trust_scores');
  DatabaseReference get _appealsRef => _database.ref('trust_appeals');

  @override
  Future<TrustModel> calculateTrustScore(String userId) async {
    try {
      final snapshot = await _trustRef.child(userId).get();
      if (!snapshot.exists) {
        throw ServerException('No trust data found for user');
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return TrustModel.fromJson(userId, data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<TrustModel> updateReputation(
      String userId, String event, Map<String, dynamic> data) async {
    try {
      await _trustRef.child(userId).update({
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      final snapshot = await _trustRef.child(userId).get();
      if (!snapshot.exists) {
        throw ServerException('Trust data not found after update');
      }
      final result = Map<String, dynamic>.from(snapshot.value as Map);
      return TrustModel.fromJson(userId, result);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<String>> getUsersAboveTrustThreshold(int threshold) async {
    try {
      final snapshot =
          await _trustRef.orderByChild('score').startAt(threshold).get();
      if (!snapshot.exists) return [];

      final userIds = <String>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map != null) {
        map.forEach((key, value) {
          final data = Map<String, dynamic>.from(value as Map);
          final score = data['score'] as int? ?? 0;
          if (score >= threshold) {
            userIds.add(key);
          }
        });
      }
      return userIds;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<TrustModel> getTrustProfile(String userId) async {
    try {
      final snapshot = await _trustRef.child(userId).get();
      if (!snapshot.exists) {
        throw ServerException('Trust profile not found');
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return TrustModel.fromJson(userId, data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<TrustAppealModel> submitAppeal(
      String userId, String reason) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();
      final appeal = TrustAppealModel(
        id: id,
        userId: userId,
        reason: reason,
        status: AppealStatus.pending,
        createdAt: now,
      );
      await _appealsRef.child(id).set(appeal.toJson());
      return appeal;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<TrustAppealModel>> getAppeals(String userId) async {
    try {
      final snapshot =
          await _appealsRef.orderByChild('userId').equalTo(userId).get();
      if (!snapshot.exists) return [];

      final appeals = <TrustAppealModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map != null) {
        map.forEach((key, value) {
          appeals.add(TrustAppealModel.fromJson(
              key, Map<String, dynamic>.from(value as Map)));
        });
      }
      appeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return appeals;
    } catch (e) {
      throw ServerException();
    }
  }
}
