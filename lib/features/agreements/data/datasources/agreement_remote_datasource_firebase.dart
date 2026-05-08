import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/agreements/data/datasources/agreement_remote_datasource.dart';
import 'package:myapp/features/agreements/data/models/agreement_model.dart';

class AgreementRemoteDataSourceFirebase implements AgreementRemoteDataSource {
  final FirebaseDatabase _database;

  AgreementRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _agreementsRef => _database.ref('agreements');

  @override
  Future<void> createAgreement(AgreementModel agreement) async {
    try {
      await _agreementsRef.child(agreement.id).set(agreement.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateAgreement(
      String agreementId, Map<String, dynamic> data) async {
    try {
      await _agreementsRef.child(agreementId).update(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<AgreementModel?> getAgreement(String agreementId) async {
    try {
      final snapshot = await _agreementsRef.child(agreementId).get();
      if (!snapshot.exists) return null;

      final data =
          Map<String, dynamic>.from(snapshot.value as Map);
      return AgreementModel.fromJson(agreementId, data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<AgreementModel>> fetchAgreementsForUser(String userId) async {
    try {
      // Query agreements where user is either initiator or partner
      // Firebase RTDB doesn't support OR queries, so we query both and merge
      final initiatorSnapshot = await _agreementsRef
          .orderByChild('initiatorId')
          .equalTo(userId)
          .get();

      final partnerSnapshot = await _agreementsRef
          .orderByChild('partnerId')
          .equalTo(userId)
          .get();

      final agreementMap = <String, AgreementModel>{};

      if (initiatorSnapshot.exists) {
        final map = initiatorSnapshot.value is Map
            ? Map<String, dynamic>.from(
                initiatorSnapshot.value as Map)
            : null;
        if (map != null) {
          map.forEach((key, value) {
            agreementMap[key] = AgreementModel.fromJson(
                key, Map<String, dynamic>.from(value as Map));
          });
        }
      }

      if (partnerSnapshot.exists) {
        final map = partnerSnapshot.value is Map
            ? Map<String, dynamic>.from(
                partnerSnapshot.value as Map)
            : null;
        if (map != null) {
          map.forEach((key, value) {
            agreementMap[key] = AgreementModel.fromJson(
                key, Map<String, dynamic>.from(value as Map));
          });
        }
      }

      final agreements = agreementMap.values.toList();
      agreements.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return agreements;
    } catch (e) {
      throw ServerException();
    }
  }
}
